// MotionManager.swift
// Updated for current Core Motion (iOS 17+/Swift 5.9+)

import CoreMotion
import Foundation

// MARK: - Constants
private enum MotionConstants {
    static let calibrationInterval: TimeInterval = 0.1
    static let defaultStreamInterval: TimeInterval = 1.0 / 60.0
    static let queueName: String = "com.iypc-team.motionQueue"
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
    
    // Public initializer to fix "inaccessible due to 'private' protection level"
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
        
        try await withCheckedThrowingContinuation { continuation in
            motionManager.deviceMotionUpdateInterval = MotionConstants.calibrationInterval
            motionManager.startDeviceMotionUpdates(to: motionQueue) { motion, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let motion else {
                    continuation.resume(throwing: MotionError.calibrationFailed)
                    return
                }
                
                let accuracy = motion.magneticField.accuracy
                if accuracy == .uncalibrated || accuracy == .low {
                    print("⚠️ Weak magnetic calibration: \(accuracy)")
                }
                
                self.referenceAttitude = motion.attitude
                self.motionManager.stopDeviceMotionUpdates()
                continuation.resume()
            }
        }
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
