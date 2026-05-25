// MotionManager.swift
// 

import CoreMotion
import Foundation

// MARK: - Constants
private enum MotionConstants {
    static let calibrationInterval: TimeInterval = 0.1
    static let defaultStreamInterval: TimeInterval = 1.0 / 60.0
    static let queueName: String = "com.iypc-team.motionQueue"
    // FIX: Allow a short warm-up window before flagging poor calibration.
    // The magnetometer is always uncalibrated on the very first sample —
    // skipping the first few samples prevents a misleading false warning.
    static let calibrationWarmupSamples: Int = 5
}

// MARK: - CMMagneticFieldCalibrationAccuracy readable description
// FIX: CMMagneticFieldCalibrationAccuracy has no CustomStringConvertible
// conformance, so string interpolation prints "CMMagneticFieldCalibrationAccuracy
// (rawValue: -1)" instead of a human-readable name. This extension fixes that.
extension CMMagneticFieldCalibrationAccuracy: CustomStringConvertible {
    public var description: String {
        switch self {
        case .uncalibrated: return "uncalibrated"
        case .low:          return "low"
        case .medium:       return "medium"
        case .high:         return "high"
        @unknown default:   return "unknown(rawValue: \(rawValue))"
        }
    }
}

// MARK: - CMAttitude Extension
extension CMAttitude {
    func relative(to reference: CMAttitude) -> CMAttitude {
        let copy = self.copy() as! CMAttitude
        copy.multiply(byInverseOf: reference)
        return copy
    }
    
    var attitudeQuaternion: AttitudeQuaternion {
        AttitudeQuaternion(quaternion: self.quaternion)
    }
}

// MARK: - Data Models
struct AttitudeQuaternion: Sendable {
    let quaternion: CMQuaternion
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    init(quaternion: CMQuaternion) {
        self.quaternion = quaternion
        self.roll = atan2(2 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z),
                          1 - 2 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y))
        self.pitch = asin(max(-1.0, min(1.0, 2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x))))
        self.yaw = atan2(2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
                         1 - 2 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z))
    }
}

struct MotionData: Sendable {
    let attitude: AttitudeQuaternion
    let gravity: CMAcceleration
    let rotationRate: CMRotationRate
    let magneticField: CMCalibratedMagneticField?
    let timestamp: TimeInterval
}

// MARK: - Motion Errors
enum MotionError: Error, LocalizedError {
    case unavailable
    case calibrationFailed
    case poorMagneticCalibration(CMMagneticFieldCalibrationAccuracy)
    
    var errorDescription: String? {
        switch self {
        case .unavailable: return "Device motion unavailable"
        case .calibrationFailed: return "Calibration failed"
        case .poorMagneticCalibration(let acc): return "Poor magnetic calibration: \(acc)"
        }
    }
}

// MARK: - Motion Manager
actor MotionManager {
    
    private let motionManager: CMMotionManager
    private let motionQueue: OperationQueue
    private var referenceAttitude: CMAttitude?
    
    public init() {
        self.motionManager = CMMotionManager()
        self.motionQueue = OperationQueue()
        self.motionQueue.name = MotionConstants.queueName
        self.motionQueue.maxConcurrentOperationCount = 1
    }
    
    func calibrate() async throws {
        guard motionManager.isDeviceMotionAvailable else {
            throw MotionError.unavailable
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            motionManager.deviceMotionUpdateInterval = MotionConstants.calibrationInterval
            
            // FIX: Track sample count so we skip the calibration warning
            // during the magnetometer warm-up window. rawValue -1 (.uncalibrated)
            // on sample 0 is normal and not a true problem.
            var sampleCount = 0
            
            motionManager.startDeviceMotionUpdates(to: motionQueue) { [weak self] motion, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let motion else {
                    continuation.resume(throwing: MotionError.calibrationFailed)
                    return
                }
                
                sampleCount += 1
                
                // Only log a calibration warning after the warm-up window,
                // so the inevitable first-sample uncalibrated state is silent.
                let accuracy = motion.magneticField.accuracy
                if sampleCount > MotionConstants.calibrationWarmupSamples,
                   accuracy == .uncalibrated || accuracy == .low {
                    // Now uses the readable description extension: "uncalibrated" or "low"
                    print("⚠️ Weak magnetic calibration: \(accuracy)")
                }
                
                let capturedAttitude = motion.attitude
                Task { [weak self] in
                    await self?.storeReferenceAndStop(capturedAttitude)
                    continuation.resume()
                }
            }
        }
    }
    
    // Actor-isolated helper — safely called from within a Task
    private func storeReferenceAndStop(_ attitude: CMAttitude) {
        referenceAttitude = attitude
        motionManager.stopDeviceMotionUpdates()
    }
    
    func startDeviceMotionUpdates(interval: TimeInterval = MotionConstants.defaultStreamInterval,
                                  handler: @escaping (MotionData) -> Void) {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates(to: motionQueue) { motion, error in
            guard let motion, error == nil else { return }
            
            let data = MotionData(
                attitude: motion.attitude.attitudeQuaternion,
                gravity: motion.gravity,
                rotationRate: motion.rotationRate,
                magneticField: motion.magneticField,
                timestamp: motion.timestamp
            )
            handler(data)
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        referenceAttitude = nil
    }
    
    var currentMagneticAccuracy: CMMagneticFieldCalibrationAccuracy? {
        motionManager.deviceMotion?.magneticField.accuracy
    }
}
