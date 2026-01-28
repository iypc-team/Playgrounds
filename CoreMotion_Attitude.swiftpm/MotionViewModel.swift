//  MotionViewModel.swift
//    
//  recalibrate()

import Foundation
import CoreMotion
import Combine
import Dispatch
import simd

// MARK: - MotionSample Abstraction
protocol MotionSample {
    var simdQuaternion: simd_quatd { get }
}

extension CMDeviceMotion: MotionSample {
    var simdQuaternion: simd_quatd {
        simd_quatd(
            ix: attitude.quaternion.x,
            iy: attitude.quaternion.y,
            iz: attitude.quaternion.z,
            r:  attitude.quaternion.w
        )
    }
}

// MARK: - Motion Stream Provider
final class MotionStreamProvider {
    
    private let manager = CMMotionManager()
    private let interval: TimeInterval = 1.0 / 60.0
    
    private let motionQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "MotionStreamProvider.CoreMotionQueue"
        q.qualityOfService = .userInitiated
        q.maxConcurrentOperationCount = 1   // preserve ordering
        return q
    }()
    
    func stream() -> AsyncStream<MotionSample> {
        AsyncStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish()
                return
            }
            
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(
                using: .xArbitraryZVertical,
                to: motionQueue
            ) { motion, _ in
                if let motion {
                    continuation.yield(motion)
                }
            }
            
            continuation.onTermination = { _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}

// MARK: - MotionViewModel

@MainActor
final class MotionViewModel: ObservableObject {
    
    // MARK: Published UI Values
    
    @Published var roll:  Double = 0
    @Published var pitch: Double = 0
    @Published var yaw:   Double = 0
    @Published var rotationMatrix = matrix_identity_double3x3
    
    // MARK: Combine Publisher
    
    let motionPublisher = PassthroughSubject<simd_quatd, Never>()
    
    // MARK: Internal State
    
    private let provider = MotionStreamProvider()
    private var task: Task<Void, Never>?
    
    private var referenceQuat: simd_quatd?
    private var filteredQuat: simd_quatd?
    private var lastRawQuat: simd_quatd?
    private var lastAngularVelocity: Double = 0
    
    private let updateInterval = 1.0 / 60.0
    
    // MARK: Constants
    
    private enum Constants {
        static let deadZoneOmega = 0.02
        static let minAlpha = 0.04
        static let maxAlpha = 0.40
        static let jerkGain = 0.35
        static let convergenceEpsilon = 0.01
        static let maxJerk = 1_000.0
    }
    
    // MARK: Lifecycle
    
    func startStream() {
        print("startStream()")
        guard task == nil else { return }
        
        task = Task {
            for await sample in provider.stream() {
                process(sample: sample)
            }
        }
    }
    
    func stopStream() {
        print("stop()")
        task?.cancel()
        task = nil
        filteredQuat = nil
        lastRawQuat = nil
        lastAngularVelocity = 0
    }
    
    func recalibrate() {
        print("recalibrate()")
        
        // 1. Choose the most stable available reference (RAW preferred)
        let newReference: simd_quatd
        if let lrq = lastRawQuat {
            print("lrq: \(lrq) ")
            newReference = lrq.normalized
        } else if let fq = filteredQuat {
            print("fq: \(fq )")
            newReference = fq.normalized
        } else {
            print("No valid reference, nothing to do here")
            referenceQuat = nil
            return
        }
        
        let refInv = newReference.inverse
        print("refInv: \( refInv)")
        
        // 2. Rebase filtered state into the new reference frame (PRESERVE continuity)
        if let fq = filteredQuat {
            filteredQuat = (fq * refInv).normalized
        }
        
        // 3. Rebase last raw sample so angular velocity remains continuous
        if let lrq = lastRawQuat {
            lastRawQuat = (lrq * refInv).normalized
        }
        
        // 4. Update reference
        referenceQuat = newReference
        
        // 5. DO NOT reset lastAngularVelocity (critical for jerk stability)
        
        print("recalibration complete\n")
    }
    
    // MARK: Processing Pipeline
    private func process(sample: MotionSample) {
        let currentQuat = sample.simdQuaternion
        let relativeQuat = referenceQuat.map { currentQuat * $0.inverse } ?? currentQuat
        
        guard let previous = lastRawQuat else {
            filteredQuat = relativeQuat
            lastRawQuat = relativeQuat
            publish(relativeQuat)
            return
        }
        
        let omega = angularVelocity(from: previous, to: relativeQuat)
        let jerk = min(
            abs(omega - lastAngularVelocity) / updateInterval,
            Constants.maxJerk
        )
        
        lastAngularVelocity = omega
        
        if omega < Constants.deadZoneOmega {
            filteredQuat = simd_slerp(
                filteredQuat ?? relativeQuat,
                relativeQuat,
                Constants.convergenceEpsilon
            )
        } else {
            let alpha = min(
                Constants.maxAlpha,
                max(Constants.minAlpha, Constants.minAlpha + Constants.jerkGain * jerk)
            )
            filteredQuat = simd_slerp(
                filteredQuat ?? relativeQuat,
                relativeQuat,
                alpha
            )
        }
        
        lastRawQuat = relativeQuat
        if let fq = filteredQuat {
            publish(fq)
        }
    }
    
    // MARK: Publishing
    
    private func publish(_ q: simd_quatd) {
        rotationMatrix = simd_double3x3(q)
        
        let e = q.eulerAngles
        pitch = radiansToDegrees(e.x)
        yaw   = wrapDegrees(radiansToDegrees(e.y))
        roll  = radiansToDegrees(e.z)
        
        motionPublisher.send(q)
    }
    
    // MARK: Math
    
    private func angularVelocity(from q1: simd_quatd, to q2: simd_quatd) -> Double {
        let dot = min(1, max(-1, simd_dot(q1.vector, q2.vector)))
        let angle = 2 * acos(abs(dot))
        return angle / updateInterval
    }
    
    private func radiansToDegrees(_ r: Double) -> Double {
        r * 180 / .pi
    }
    
    private func wrapDegrees(_ d: Double) -> Double {
        var x = d.truncatingRemainder(dividingBy: 360)
        if x > 180 { x -= 360 }
        if x < -180 { x += 360 }
        return x
    }
}

// MARK: - Quaternion → Euler

private extension simd_quatd {
    var eulerAngles: SIMD3<Double> {
        let q = normalized
        let sinp = 2 * (q.real * q.imag.x - q.imag.y * q.imag.z)
        let pitch = abs(sinp) >= 1 ? copysign(.pi / 2, sinp) : asin(sinp)
        
        let yaw = atan2(
            2 * (q.real * q.imag.y + q.imag.z * q.imag.x),
            1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        )
        
        let roll = atan2(
            2 * (q.real * q.imag.z + q.imag.x * q.imag.y),
            1 - 2 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        )
        
        return SIMD3(pitch, yaw, roll)
    }
}
