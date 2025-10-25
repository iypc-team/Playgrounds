//  
//  

import CoreMotion
import Foundation

struct Quaternion {
    let w: Double
    let x: Double
    let y: Double
    let z: Double
}

final class MotionService {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    init() {
        queue.name = "MotionQueue"
        queue.maxConcurrentOperationCount = 8
        queue.qualityOfService = .background
        print(queue.underlyingQueue as Any)
    }
    
    // MARK: – Async stream of quaternions
    func quaternionStream(
        updateInterval: TimeInterval = 1.0 / 60.0   // 60 Hz by default
    ) -> AsyncThrowingStream<Quaternion, Error> {
        AsyncThrowingStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(domain: "Motion", code: 1,
                                                      userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]))
                return
            }
            
            manager.deviceMotionUpdateInterval = updateInterval
            manager.startDeviceMotionUpdates(to: queue) { motion, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let quat = motion?.attitude.quaternion else { return }
                
                let q = Quaternion(w: quat.w, x: quat.x, y: quat.y, z: quat.z)
                continuation.yield(q)
            }
            
            // Clean‑up when the consumer cancels
            continuation.onTermination = { @Sendable _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}
