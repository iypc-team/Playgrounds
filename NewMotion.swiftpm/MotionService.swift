import Foundation
import CoreMotion

//protocol MotionService {
//    func getStream() -> AsyncStream<(Double, Double)>
//}

final class MotionServiceAdapter {
    let motionManager = CMMotionManager()
    
    func attitudeQuaternionStream() -> AsyncStream<CMQuaternion> {
        AsyncStream { continuation in
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish()
                return
            }
            
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                if let attitude = motion?.attitude {
                    continuation.yield(attitude.quaternion)
                }
                if error != nil {
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                self.motionManager.stopDeviceMotionUpdates()
            }
        }
    }
    
    // Usage example in an async context:
//    Task {
//        for await quaternion in attitudeQuaternionStream() {
//            print("Quaternion: x=\(quaternion.x), y=\(quaternion.y), z=\(quaternion.z), w=\(quaternion.w)")
//        }
//    }
}
