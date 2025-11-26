// 
// 

import CoreMotion
import Foundation
import RealityKit

final class MotionProvider {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    init() {
        queue.name = "MotionQueue"
//        queue.qualityOfService = 
        manager.deviceMotionUpdateInterval = 1.0 / 60.0  // Update at 60 Hz
    }
}

extension MotionProvider {
    func quaternionStream() -> AsyncThrowingStream<simd_quatf, Error> {
        AsyncThrowingStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(domain: "Motion", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Device motion unavailable"
                ]))
                return
            }
            
            manager.startDeviceMotionUpdates(to: queue) { motion, error in
                if let error = error {
                    continuation.finish(throwing: error)
                } else if let quaternion = motion?.attitude.quaternion {
                    // Convert CMQuaternion to simd_quatf
                    let simdQuaternion = simd_quatf(
                        ix: Float(quaternion.x),
                        iy: Float(quaternion.y),
                        iz: Float(quaternion.z),
                        r: Float(quaternion.w)
                    )
                    continuation.yield(simdQuaternion)
                }
            }
            
            // Handle stream termination
            continuation.onTermination = { _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}

