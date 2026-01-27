//  MotionViewModel.swift
//    

import Foundation
import CoreMotion
import simd

final class MotionViewModel: ObservableObject {
    private let motionManager = CMMotionManager()
    private let updateInterval: Double = 1.0 / 60.0
    
    // MARK: - Quaternion State
    private var referenceQuat: simd_quatd?
    private var filteredQuat: simd_quatd?
    private var lastRawQuat: simd_quatd?
    private var lastAngularVelocity: Double = 0
    
    // MARK: - Stabilization Tuning
    private let deadZoneOmega: Double = 0.02  // rad/s
    private let minAlpha: Double = 0.04
    private let maxAlpha: Double = 0.4
    private let jerkGain: Double = 0.35
    private let deadZoneAlpha: Double = 0.01  // convergence epsilon
    
    // MARK: - Published Euler (UI Only)
    // Device frame:
    // x → pitch, y → yaw, z → roll
    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    
    // MARK: - Exported Rotation Matrix (column-major)
    @Published var rotationMatrix: simd_double3x3 = matrix_identity_double3x3
    
    init() {
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    // MARK: - Public API
    func startUpdates() {
        print("startUpdates()")
        guard motionManager.isDeviceMotionAvailable,
              !motionManager.isDeviceMotionActive else { return }
        
        let frame: CMAttitudeReferenceFrame = .xArbitraryZVertical
        guard CMMotionManager.availableAttitudeReferenceFrames().contains(frame) else { return }
        
        motionManager.startDeviceMotionUpdates(using: frame, to: .main) { [weak self] data, error in
            guard let self, let motion = data, error == nil else { return }
            self.process(motion: motion)
        }
    }
    
    func stopUpdates() {
        print("stopUpdates()")
        motionManager.stopDeviceMotionUpdates()
        filteredQuat = nil
        lastRawQuat = nil
        lastAngularVelocity = 0
    }
    
    func recalibrate() {
        print("recalibrate()")
        guard let motion = motionManager.deviceMotion else { return }
        referenceQuat = motion.simdQuaternion
        filteredQuat = nil
        lastRawQuat = nil
        lastAngularVelocity = 0
    }
    
    // MARK: - Quaternion Pipeline
    private func process(motion: CMDeviceMotion) {
        let currentQuat = motion.simdQuaternion
        let relativeQuat = referenceQuat.map { currentQuat * $0.inverse } ?? currentQuat
        
        guard let lastRaw = lastRawQuat else {
            filteredQuat = relativeQuat
            lastRawQuat = relativeQuat
            publish(quaternion: relativeQuat)
            return
        }
        
        let omega = angularVelocity(from: lastRaw, to: relativeQuat)
        let jerk = abs(omega - lastAngularVelocity) / updateInterval
        lastAngularVelocity = omega
        
        // Dead-zone stabilization with slow convergence
        if omega < deadZoneOmega {
            filteredQuat = simd_slerp(
                filteredQuat ?? relativeQuat,
                relativeQuat,
                deadZoneAlpha
            )
            publish(quaternion: filteredQuat!)
            lastRawQuat = relativeQuat
            return
        }
        
        let alpha = adaptiveAlpha(jerk: jerk)
        
        filteredQuat = simd_slerp(
            filteredQuat ?? relativeQuat,
            relativeQuat,
            alpha
        )
        
        lastRawQuat = relativeQuat
        publish(quaternion: filteredQuat!)
    }
    
    // MARK: - Publish
    private func publish(quaternion q: simd_quatd) {
        rotationMatrix = simd_double3x3(q)
        
        let euler = q.eulerAngles
        roll  = radiansToDegrees(euler.z)
        pitch = radiansToDegrees(euler.x)
        yaw   = wrapDegrees(radiansToDegrees(euler.y))
    }
    
    // MARK: - Math
    private func angularVelocity(from q1: simd_quatd, to q2: simd_quatd) -> Double {
        let dot = simd_dot(q1.vector, q2.vector)
        let clamped = min(1.0, max(-1.0, dot))
        let angle = 2 * acos(abs(clamped)) // correct quaternion equivalence
        return angle / updateInterval
    }
    
    private func adaptiveAlpha(jerk: Double) -> Double {
        let raw = minAlpha + jerkGain * jerk
        return min(maxAlpha, max(minAlpha, raw))
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

// MARK: - CoreMotion → SIMD
private extension CMDeviceMotion {
    var simdQuaternion: simd_quatd {
        simd_quatd(
            ix: attitude.quaternion.x,
            iy: attitude.quaternion.y,
            iz: attitude.quaternion.z,
            r:  attitude.quaternion.w
        )
    }
}

// MARK: - Quaternion → Euler
private extension simd_quatd {
    /// (x: pitch, y: yaw, z: roll) in radians
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
