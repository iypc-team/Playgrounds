// MotionManager.swift
// Uses deviceMotionUpdateInterval instead of manual Date-based throttling.
// Creates attitudeStream in startUpdates() so callers can safely for-await it afterwards.

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
}

final class MotionManager {
    private let motionManager = CMMotionManager()
    private var continuation: AsyncThrowingStream<AttitudeQuaternion, Error>.Continuation?
    
    // Exposed stream. Created when startUpdates(...) is called.
    private(set) var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    /// Start device motion updates and create the attitude stream.
    /// - Parameter updateInterval: desired update interval in seconds (default 1/30s).
    func startUpdates(updateInterval: TimeInterval = 1.0 / 30.0) {
        // If already started, do nothing.
        if attitudeStream != nil { return }
        
        // Configure the update interval instead of doing manual throttling.
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        attitudeStream = AsyncThrowingStream { continuation in
            self.continuation = continuation
            
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
                guard let self = self, let continuation = self.continuation else { return }
                
                if let error = error {
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
        motionManager.stopDeviceMotionUpdates()
        continuation?.finish()
        continuation = nil
        attitudeStream = nil
    }
    
    deinit {
        stopUpdates()
    }
}
