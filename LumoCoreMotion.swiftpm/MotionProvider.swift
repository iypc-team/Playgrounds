// 
//  queue delegate
// 

import CoreMotion
import Foundation

/// A thin wrapper that turns CoreMotion device‑motion updates into an AsyncStream.
struct MotionProvider {
    public let manager = CMMotionManager()
    public let updateInterval: TimeInterval
    public var queue = OperationQueue()
    
    /// Initialise with a desired sampling rate (default 60 Hz).
    init(updateInterval: TimeInterval = 1.0 / 0.1) {
        self.updateInterval = updateInterval
    }
    
    /// Async sequence of `CMDeviceMotion` values.
    func deviceMotionStream() -> AsyncStream<CMDeviceMotion> {
        // The stream is *lazy* – it won’t start until someone begins iterating.
        AsyncStream { continuation in
            // Guard against missing hardware early so we can finish the stream gracefully.
            guard manager.isDeviceMotionAvailable else {
                continuation.finish()
                return
            }
            
            manager.deviceMotionUpdateInterval = updateInterval
            
            // Choose a queue that matches your UI needs.
            // Using `.main` keeps UI work simple; a background queue reduces UI jitter.
//            let queue = OperationQueue()
            queue.qualityOfService = .background
            queue.name = "com.example.motionQueue"
            queue.maxConcurrentOperationCount = 4
            
            manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: queue) { motion, error in
                if let error = error {
                    // If you want to surface errors, switch to AsyncThrowingStream instead.
                    print("⚠️ Motion error: \(error.localizedDescription)")
                    // Optionally: continuation.finish(throwing: error)
                    return
                }
                
                if let motion = motion {
                    continuation.yield(motion)
                }
            }
            
            // This closure runs when the consumer stops iterating or the stream is deallocated.
            continuation.onTermination = { @Sendable termination in
                // Stop updates regardless of why the stream ended.
                manager.stopDeviceMotionUpdates()
                queue.cancelAllOperations()
                // You could also log the termination reason:
                // print("🔚 Stream terminated: \(termination)")
            }
        }
    }
}
