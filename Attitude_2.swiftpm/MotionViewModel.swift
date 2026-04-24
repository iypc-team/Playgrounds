//  MotionViewModel.swift
//

import Foundation
import CoreMotion
import Combine
import simd

// MARK: - MotionSample abstraction

protocol MotionSample {
    var simdQuaternion: simd_quatd { get }
}

extension CMDeviceMotion: MotionSample {
    @inline(__always)
    var simdQuaternion: simd_quatd {
        let q = attitude.quaternion
        
        guard q.x.isFinite, q.y.isFinite, q.z.isFinite, q.w.isFinite else {
            return simd_quatd(ix: 0, iy: 0, iz: 0, r: 1)
        }
        
        return simd_quatd(ix: q.x, iy: q.y, iz: q.z, r: q.w).normalized
    }
}

// MARK: - Motion stream provider

final class MotionStreamProvider {
    private let manager = CMMotionManager()
    private let interval: TimeInterval = 1.0 / 60.0
    
    private let motionQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "MotionStreamProvider.CoreMotionQueue"
        q.qualityOfService = .userInitiated
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    var isDeviceMotionAvailable: Bool {
        manager.isDeviceMotionAvailable
    }
    
    deinit {
        manager.stopDeviceMotionUpdates()
        motionQueue.cancelAllOperations()
    }
    
    func stream() -> AsyncStream<MotionSample> {
        AsyncStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish()
                return
            }
            
            motionQueue.isSuspended = false
            manager.deviceMotionUpdateInterval = interval
            
            manager.startDeviceMotionUpdates(
                // xArbitraryZVertical
                using: .xMagneticNorthZVertical,
                to: motionQueue
            ) { motion, _ in
                guard let motion else { return }
                continuation.yield(motion)
            }
            
            continuation.onTermination = { @Sendable [weak self] _ in
                guard let self else { return }
                self.motionQueue.addOperation {
                    self.manager.stopDeviceMotionUpdates()
                }
            }
        }
    }
}

// MARK: - Motion view model

@MainActor
final class MotionViewModel: ObservableObject {
    @Published private(set) var roll: Double = 0
    @Published private(set) var pitch: Double = 0
    @Published private(set) var yaw: Double = 0
    @Published private(set) var rotationMatrix = matrix_identity_double3x3
    @Published private(set) var isStreaming = false
    @Published private(set) var isMotionAvailable = false
    
    private let orientationSubject = PassthroughSubject<simd_quatd, Never>()
    var orientationPublisher: AnyPublisher<simd_quatd, Never> {
        orientationSubject.eraseToAnyPublisher()
    }
    
    private let provider: MotionStreamProvider
    private var streamingTask: Task<Void, Never>?
    
    private var referenceQuat: simd_quatd?
    private var filteredQuat: simd_quatd?
    private var lastRawQuat: simd_quatd?
    private var lastAngularVelocity: Double = 0
    
    private let updateInterval = 1.0 / 60.0
    
    var canRecalibrate: Bool {
        lastRawQuat != nil || filteredQuat != nil
    }
    
    private enum Constants {
        static let deadZoneOmega      = 0.02
        static let minAlpha           = 0.04
        static let maxAlpha           = 0.40
        static let jerkGain           = 0.35
        static let convergenceEpsilon = 0.01
        static let maxJerk            = 1_000.0
    }
    
    init(provider: MotionStreamProvider = MotionStreamProvider()) {
        self.provider = provider
        self.isMotionAvailable = provider.isDeviceMotionAvailable
    }
    
    func startStream() {
        guard streamingTask == nil else { return }
        
        isMotionAvailable = provider.isDeviceMotionAvailable
        guard isMotionAvailable else {
            isStreaming = false
            return
        }
        
        isStreaming = true
        
        streamingTask = Task { [weak self] in
            guard let self else { return }
            
            for await sample in provider.stream() {
                if Task.isCancelled { break }
                process(sample: sample)
            }
            
            self.streamingTask = nil
            self.isStreaming = false
        }
    }
    
    func stop() {
        Task { [weak self] in
            await self?.stopStream()
        }
    }
    
    func stopStream() async {
        guard let task = streamingTask else { return }
        
        task.cancel()
        await task.value
        
        streamingTask = nil
        isStreaming = false
        
        filteredQuat = nil
        lastRawQuat = nil
        lastAngularVelocity = 0
        referenceQuat = nil
        
        roll = 0
        pitch = 0
        yaw = 0
        rotationMatrix = matrix_identity_double3x3
    }
    
    @discardableResult
    func recalibrate() -> Bool {
        print("\nfunc recalibrate()")
        let newReference: simd_quatd
        
        if let raw = lastRawQuat {
            newReference = raw.normalized
        } else if let filtered = filteredQuat {
            newReference = filtered.normalized
        } else {
            return false
        }
        
        let inv = newReference.inverse
        
        if let filtered = filteredQuat {
            filteredQuat = (filtered * inv).normalized
        }
        
        if let raw = lastRawQuat {
            lastRawQuat = (raw * inv).normalized
        }
        
        referenceQuat = newReference
        print("referenceQuat: \(String(describing: referenceQuat))")
        if let filteredQuat {
            publish(filteredQuat)
        }
        
        return true
    }
    
    private func process(sample: MotionSample) {
        let currentQuat = sample.simdQuaternion.normalized
        let relativeQuat = referenceQuat.map { currentQuat * $0.inverse } ?? currentQuat
        
        guard let previous = lastRawQuat else {
            filteredQuat = relativeQuat
            lastRawQuat = relativeQuat
            publish(relativeQuat)
            return
        }
        
        let omega = angularVelocity(from: previous, to: relativeQuat)
        guard omega.isFinite else { return }
        
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
                max(
                    Constants.minAlpha,
                    Constants.minAlpha + Constants.jerkGain * jerk
                )
            )
            
            filteredQuat = simd_slerp(
                filteredQuat ?? relativeQuat,
                relativeQuat,
                alpha
            )
        }
        
        lastRawQuat = relativeQuat
        
        if let filteredQuat {
            publish(filteredQuat)
        }
    }
    
    private func publish(_ quat: simd_quatd) {
        rotationMatrix = simd_double3x3(quat)
        
        let e = quat.eulerAngles
        let newPitch = radiansToDegrees(e.x)
        let newYaw = wrapDegrees(radiansToDegrees(e.y))
        let newRoll = radiansToDegrees(e.z)
        
        if pitch != newPitch { pitch = newPitch }
        if yaw != newYaw { yaw = newYaw }
        if roll != newRoll { roll = newRoll }
        
        orientationSubject.send(quat)
    }
    
    private func angularVelocity(from q1: simd_quatd, to q2: simd_quatd) -> Double {
        let dot = simd_dot(q1.vector, q2.vector)
        let clamped = min(1.0, max(-1.0, dot))
        
        guard clamped.isFinite else { return 0 }
        
        let angle = 2.0 * acos(abs(clamped))
        return angle / updateInterval
    }
    
    @inline(__always)
    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }
    
    @inline(__always)
    private func wrapDegrees(_ degrees: Double) -> Double {
        var value = degrees.truncatingRemainder(dividingBy: 360.0)
        if value > 180.0 { value -= 360.0 }
        if value < -180.0 { value += 360.0 }
        return value
    }
}

private extension simd_quatd {
    var eulerAngles: SIMD3<Double> {
        let q = normalized
        
        let sinp = 2.0 * (q.real * q.imag.x - q.imag.y * q.imag.z)
        let pitch = abs(sinp) >= 1.0
        ? copysign(.pi / 2.0, sinp)
        : asin(sinp)
        
        let yaw = atan2(
            2.0 * (q.real * q.imag.y + q.imag.z * q.imag.x),
            1.0 - 2.0 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        )
        
        let roll = atan2(
            2.0 * (q.real * q.imag.z + q.imag.x * q.imag.y),
            1.0 - 2.0 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        )
        
        return SIMD3(pitch, yaw, roll)
    }
}
