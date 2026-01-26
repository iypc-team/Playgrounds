//  MotionViewModel.swift
//  

import Foundation
import CoreMotion
import simd

final class MotionViewModel: ObservableObject {
    
    private let motionManager = CMMotionManager()
    private let updateInterval: Double = 1.0 / 60.0
    
    // Calibration reference
    private var referenceQuat: simd_quatd?
    
    // SLERP filter state
    private var filteredQuat: simd_quatd?
    
    // Smoothing factor (0 = frozen, 1 = no smoothing)
    private let slerpAlpha: Double = 0.15
    
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    // MARK: - Public API
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        guard !motionManager.isDeviceMotionActive else { return }
        
        let referenceFrame: CMAttitudeReferenceFrame = .xArbitraryZVertical
        
        guard CMMotionManager.availableAttitudeReferenceFrames()
            .contains(referenceFrame) else { return }
        
        motionManager.startDeviceMotionUpdates(
            using: referenceFrame,
            to: .main
        ) { [weak self] data, error in
            guard
                let self,
                let motion = data,
                error == nil
            else { return }
            
            self.process(motion: motion)
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        filteredQuat = nil
    }
    
    func recalibrate() {
        guard let motion = motionManager.deviceMotion else { return }
        
        referenceQuat = simd_quatd(
            ix: motion.attitude.quaternion.x,
            iy: motion.attitude.quaternion.y,
            iz: motion.attitude.quaternion.z,
            r:  motion.attitude.quaternion.w
        )
        
        filteredQuat = nil
    }
    
    // MARK: - Quaternion Pipeline
    
    private func process(motion: CMDeviceMotion) {
        
        let currentQuat = simd_quatd(
            ix: motion.attitude.quaternion.x,
            iy: motion.attitude.quaternion.y,
            iz: motion.attitude.quaternion.z,
            r:  motion.attitude.quaternion.w
        )
        
        // Apply calibration (relative orientation)
        let relativeQuat: simd_quatd
        if let ref = referenceQuat {
            relativeQuat = currentQuat * ref.inverse
        } else {
            relativeQuat = currentQuat
        }
        
        // Initialize filter on first frame
        if filteredQuat == nil {
            filteredQuat = relativeQuat
        } else {
            filteredQuat = simd_slerp(filteredQuat!, relativeQuat, slerpAlpha)
        }
        
        publish(quaternion: filteredQuat!)
    }
    
    // MARK: - Publish
    
    private func publish(quaternion q: simd_quatd) {
        
        let euler = q.eulerAngles
        
        roll  = radiansToDegrees(euler.z)
        pitch = radiansToDegrees(euler.x)
        yaw   = wrapDegrees(radiansToDegrees(euler.y))
    }
    
    // MARK: - Math Helpers
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }
    
    /// Normalize angle to [-180, +180]
    private func wrapDegrees(_ degrees: Double) -> Double {
        var wrapped = degrees.truncatingRemainder(dividingBy: 360)
        if wrapped > 180 { wrapped -= 360 }
        if wrapped < -180 { wrapped += 360 }
        return wrapped
    }
}

// MARK: - simd_quatd → Euler Conversion

private extension simd_quatd {
    
    /// Euler angles in radians (x: pitch, y: yaw, z: roll)
    var eulerAngles: SIMD3<Double> {
        
        let q = normalized
        
        // Pitch (X)
        let sinp = 2 * (q.real * q.imag.x - q.imag.y * q.imag.z)
        let pitch = abs(sinp) >= 1
        ? copysign(.pi / 2, sinp)
        : asin(sinp)
        
        // Yaw (Y)
        let yaw = atan2(
            2 * (q.real * q.imag.y + q.imag.z * q.imag.x),
            1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        )
        
        // Roll (Z)
        let roll = atan2(
            2 * (q.real * q.imag.z + q.imag.x * q.imag.y),
            1 - 2 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        )
        
        return SIMD3(pitch, yaw, roll)
    }
}
