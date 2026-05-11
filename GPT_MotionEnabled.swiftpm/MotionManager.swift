// MotionManager.swift
//

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
    
    // Computed properties for Euler angles (roll, pitch, yaw) derived from quaternion
    // Formulas based on standard quaternion to Euler conversion (assuming ZYX order)
    
    var roll: Double {
        atan2(
            2 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z),
            1 - 2 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y)
        )
    }
    
    var pitch: Double {
        asin(
            max(
                -1.0,
                 min(
                    1.0,
                    2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x)
                 )
            )
        )
    }
    
    var yaw: Double {
        atan2(
            2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
            1 - 2 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z)
        )
    }
}

enum MotionError: Error {
    case unavailable
}

actor MotionManager {
    
    private let motionManager = CMMotionManager()
    
    // ✅ Fix #2: Dedicated background OperationQueue for CoreMotion callbacks.
    // Avoids delivering 60 FPS updates on the main thread and causing UI jank.
    // SceneViewModel already uses `await MainActor.run` for all SceneKit/UI updates.
    
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.DF22_MotionEnabled.motionQueue"
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /// Start device motion updates and create the attitude stream.
    /// - Parameter updateInterval: Desired update interval in seconds
    ///   (default 1/60s for 60 FPS; lower for battery savings e.g. 1/30s or 1/5s).
    
    func makeAttitudeStream(
        updateInterval: TimeInterval = 1.0 / 60.0
    ) -> AsyncThrowingStream<AttitudeQuaternion, Error> {
        
        AsyncThrowingStream(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.unavailable)
                return
            }
            
            motionManager.deviceMotionUpdateInterval = updateInterval
            
            continuation.onTermination = { [weak motionManager] _ in
                motionManager?.stopDeviceMotionUpdates()
            }
            
            motionManager.startDeviceMotionUpdates(
                using: .xArbitraryCorrectedZVertical,
                to: motionQueue
            ) { motion, error in
                
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion else { return }
                
                continuation.yield(
                    AttitudeQuaternion(
                        quaternion: motion.attitude.quaternion
                    )
                )
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

