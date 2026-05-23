// MotionManager.swift
// 

import CoreMotion

// MARK: - CMAttitude Extension for Reusability
extension CMAttitude {
    /// Returns a new attitude relative to the given reference attitude
    func relative(to reference: CMAttitude) -> CMAttitude {
        let copy = self.copy() as! CMAttitude
        copy.multiply(byInverseOf: reference)
        return copy
    }
    
    /// Convenience computed property for AttitudeQuaternion
    var attitudeQuaternion: AttitudeQuaternion {
        AttitudeQuaternion(quaternion: self.quaternion)
    }
}

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    init(quaternion: CMQuaternion) {
        self.quaternion = quaternion
        self.roll = atan2(
            2 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z),
            1 - 2 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y)
        )
        self.pitch = asin(
            max(-1.0, min(1.0, 2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x)))
        )
        self.yaw = atan2(
            2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
            1 - 2 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z)
        )
    }
}

struct MotionOffset {
    let quaternion: CMQuaternion
    static let zero = MotionOffset(quaternion: CMQuaternion(x: 0, y: 0, z: 0, w: 1))
}

enum MotionError: Error {
    case unavailable
    case motionUpdateFailed
}

actor MotionManager {
    static let shared = MotionManager()
    
    private let motionManager = CMMotionManager()
    private var referenceAttitude: CMAttitude?
    
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.DefconUniverse.motionQueue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: - Calibration
    func calibrate() async {
        await withCheckedContinuation { continuation in
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: motionQueue) { motion, _ in
                self.referenceAttitude = motion?.attitude
                self.motionManager.stopDeviceMotionUpdates()
                continuation.resume()
            }
        }
        print("✅ Calibration completed using reference attitude.")
    }
    
    // MARK: - Explicit Cleanup
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        referenceAttitude = nil
        print("🛑 MotionManager stopped.")
    }
    
    // MARK: - Stream
    func makeAttitudeStream(updateInterval: TimeInterval = 1.0 / 60.0) -> AsyncThrowingStream<AttitudeQuaternion, Error> {
        AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.unavailable)
                return
            }
            
            motionManager.startDeviceMotionUpdates(
                using: .xArbitraryCorrectedZVertical,
                to: motionQueue
            ) { motion, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let motion = motion else {
                    continuation.finish(throwing: MotionError.motionUpdateFailed)
                    return
                }
                
                let attitudeToUse = self.referenceAttitude != nil 
                ? motion.attitude.relative(to: self.referenceAttitude!) 
                : motion.attitude
                
                continuation.yield(attitudeToUse.attitudeQuaternion)
            }
            
            continuation.onTermination = { _ in
                self.motionManager.stopDeviceMotionUpdates()
            }
        }
    }
}
