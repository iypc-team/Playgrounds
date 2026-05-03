// MotionManager.swift
// Exposes device attitude as an AsyncThrowingStream and ensures the CMMotionManager
// is stopped on stream termination (normal, error, or consumer cancellation).

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
    
    // Computed properties for Euler angles (roll, pitch, yaw) derived from quaternion
    // Formulas based on standard quaternion to Euler conversion (assuming ZYX order)
    var roll: Double {
        atan2(2 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z),
              1 - 2 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y))
    }
    
    var pitch: Double {
        asin(max(-1.0, min(1.0, 2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x))))
    }
    
    var yaw: Double {
        atan2(2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
              1 - 2 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z))
    }
}

final class MotionManager {
    private let motionManager = CMMotionManager()
    private var continuation: AsyncThrowingStream<AttitudeQuaternion, Error>.Continuation?
    
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
    
    // Exposed stream. Created when startUpdates() is called.
    private(set) var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    /// Start device motion updates and create the attitude stream.
    /// - Parameter updateInterval: Desired update interval in seconds
    ///   (default 1/60s for 60 FPS; lower for battery savings e.g. 1/30s or 1/5s).
    func startUpdates(updateInterval: TimeInterval = 1.0 / 60.0) {
        // If already started, do nothing.
        if attitudeStream != nil { return }
        
        // Configure the update interval instead of doing manual throttling.
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        attitudeStream = AsyncThrowingStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            // Hold on to the continuation so handlers can yield/finish later.
            self.continuation = continuation
            
            // ✅ Fix #1: [weak self] added to onTermination to prevent a retain cycle.
            // onTermination is invoked on an arbitrary thread by the Swift runtime,
            // so all access is safely guarded through weak self.
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.motionManager.stopDeviceMotionUpdates()
                self?.continuation = nil
                self?.attitudeStream = nil
            }
            
            guard self.motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(
                    domain: "MotionManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]
                ))
                return
            }
            
            // ✅ Fix #2: CoreMotion callbacks delivered on `motionQueue` (background),
            // not `.main`. SceneViewModel's startMotionUpdates() dispatches to
            // MainActor for all SceneKit/UI updates.
            self.motionManager.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical,
                to: self.motionQueue
            ) { [weak self] motion, error in
                guard let self = self, let continuation = self.continuation else {
                    self?.motionManager.stopDeviceMotionUpdates()
                    return
                }
                
                if let error = error {
                    // Stop updates before finishing the stream with error
                    // to avoid leaving CMMotionManager running.
                    self.motionManager.stopDeviceMotionUpdates()
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion = motion else { return }
                
                // Yield each device motion sample at the configured updateInterval.
                continuation.yield(AttitudeQuaternion(quaternion: motion.attitude.quaternion))
            }
        }
    }
    
    /// Stop updates and finish the stream.
    func stopUpdates() {
        // Stop the CMMotionManager immediately.
        motionManager.stopDeviceMotionUpdates()
        // Finish the continuation if present (will also trigger onTermination).
        continuation?.finish()
        continuation = nil
        attitudeStream = nil
    }
    
    deinit {
        stopUpdates()
    }
}
