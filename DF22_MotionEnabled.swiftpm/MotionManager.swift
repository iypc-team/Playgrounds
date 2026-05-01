// MotionManager.swift
// Exposes device attitude as an AsyncThrowingStream and ensures the CMMotionManager
// is stopped on stream termination (normal, error, or consumer cancellation).
// updateInterval: 

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
        asin(2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x))
    }
    
    var yaw: Double {
        atan2(2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
              1 - 2 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z))
    }
}

final class MotionManager {
    private let motionManager = CMMotionManager()
    private var continuation: AsyncThrowingStream<AttitudeQuaternion, Error>.Continuation?
    
    // Exposed stream. Created when startUpdates(...) is called.
    private(set) var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    /// Start device motion updates and create the attitude stream.
    /// - Parameter updateInterval: Desired update interval in seconds (default 1/60s for high-frequency updates; lower for battery savings, e.g., 1/30s or 1/5s as used elsewhere in the app).
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
            
            // Ensure we stop the motion manager when the stream is terminated
            // (consumer cancellation, finish, or error).
            continuation.onTermination = { @Sendable _ in
                // Stop device motion updates and clear references.
                self.motionManager.stopDeviceMotionUpdates()
                self.continuation = nil
                self.attitudeStream = nil
            }
            
            guard self.motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(
                    domain: "MotionManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]
                ))
                return
            }
            
            // Start device motion updates; handler runs on the provided OperationQueue (.main here).
            self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
                guard let self = self, let continuation = self.continuation else {
                    // If we don't have a continuation, ensure the underlying manager is stopped.
                    self?.motionManager.stopDeviceMotionUpdates()
                    return
                }
                
                if let error = error {
                    // Stop updates before finishing the stream with error to avoid leaving CMMotionManager running.
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
