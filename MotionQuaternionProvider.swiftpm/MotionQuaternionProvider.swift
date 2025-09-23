// (Lumo) CoreMotion Attitude Quaternion AsyncStream
// MotionQuaternionProvider  09/17/2025-1
// queue

import CoreMotion
import Foundation

/// A singleton wrapper around CMMotionManager that exposes an async sequence of quaternions.
final class MotionQuaternionProvider {
    public let manager = CMMotionManager()
    public let queue = OperationQueue()  // Background queue for sensor callbacks
    
    /// Desired update interval (seconds). Adjust as needed.
    var updateInterval: TimeInterval = 1.0 / 1   // 60 Hz by default
    
    init() {
        queue.name = "MotionQueue"
//        print("queue.qualityOfService: \(queue.qualityOfService) ")
        manager.deviceMotionUpdateInterval = updateInterval
    }
    
    /// Returns an AsyncSequence that yields `CMQuaternion` values.
    func quaternionStream() -> AsyncStream<CMQuaternion> {
        // Ensure the device can provide attitude data.
        guard manager.isDeviceMotionAvailable else {
            return AsyncStream { continuation in
                continuation.finish()
            }
        }
        // Start updates if they aren’t already running.
        if !manager.isDeviceMotionActive {
            manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
                                             to: queue) { _, _ in /* no‑op */ }
        }
        
        // Create the async stream.
        return AsyncStream { continuation in
            // Capture a weak reference to avoid retain cycles.
            let handler: CMDeviceMotionHandler = {  (motion, error) in
                guard let motion = motion, error == nil else {
                    // Propagate the error downstream if you wish.
                    continuation.finish()
                    return
                }
                // Push the latest quaternion onto the stream.
                print("motion: \(motion)  ")
                continuation.yield(motion.attitude.quaternion)
            }
            
            // Register the callback.
            self.manager.startDeviceMotionUpdates(to: self.queue, withHandler: handler)
            
            // Clean‑up when the consumer stops iterating.
            continuation.onTermination = { @Sendable _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}
