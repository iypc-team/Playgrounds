// 
// 

import CoreMotion
import Foundation

final class MotionProvider {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()          // background queue for sensor callbacks
    
    init() {
        // Choose a reasonable update interval (e.g., 60 Hz)
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
}

extension MotionProvider {
    /// An async sequence that yields the latest attitude quaternion.
    func quaternionStream() -> AsyncStream<CMQuaternion> {
        AsyncStream(unfolding: <#T##() async -> Element?#>, onCancel: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>) { continuation in
            // Start receiving device‑motion updates
            manager.startDeviceMotionUpdates(to: queue) { motion, error in
                if let error = error {
                    // Propagate the error and finish the stream
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let quat = motion?.attitude.quaternion else { return }
                continuation.yield(quat)               // push the new quaternion downstream
            }
            
            // When the consumer stops iterating, stop the sensor
            continuation.onTermination = { @Sendable  in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}
