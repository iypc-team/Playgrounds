// MotionManager.swift
// 

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
    
    // Cached Euler angles to avoid recomputing atan2/asin per access
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    init(quaternion: CMQuaternion) {
        self.quaternion = quaternion
        // Precompute Euler angles from quaternion
        // Formulas based on standard quaternion to Euler conversion (assuming ZYX order)
        self.roll = atan2(
            2 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z),
            1 - 2 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y)
        )
        self.pitch = asin(
            max(
                -1.0,
                 min(
                    1.0,
                    2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x)
                 )
            )
        )
        self.yaw = atan2(
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
    
    // Fix #2: Dedicated background OperationQueue for CoreMotion callbacks.
    // Avoids delivering updates on the main thread and causing UI jank.
    // SceneViewModel already uses `await MainActor.run` for all SceneKit/UI updates.
    // Changed QoS to .userInitiated to balance priority without starving other tasks.
    
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.DF22_MotionEnabled.motionQueue"
        queue.qualityOfService = .userInitiated  // Adjusted for better resource sharing
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /// Start device motion updates and create the attitude stream.
    /// - Parameter updateInterval: Desired update interval in seconds
    ///   (default 1/30s for 30 FPS: lower for battery savings).
    /// - Parameter throttleInterval: Minimum time between yields (optional throttling).
    
    func makeAttitudeStream(
        updateInterval: TimeInterval = 1.0 / 30.0,
        throttleInterval: TimeInterval? = nil
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
            
            var lastYieldTime: TimeInterval? = nil
            
            motionManager.startDeviceMotionUpdates(
                using: .xArbitraryCorrectedZVertical,
                to: motionQueue
            ) { motion, error in
                
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion else { return }
                
                let currentTime = ProcessInfo.processInfo.systemUptime
                if let throttle = throttleInterval, let last = lastYieldTime, currentTime - last < throttle {
                    return  // Skip this update to throttle
                }
                
                lastYieldTime = currentTime
                
                continuation.yield(
                    AttitudeQuaternion(quaternion: motion.attitude.quaternion)
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


