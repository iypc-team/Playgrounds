//// 
//// 
//
//import Foundation
//import CoreMotion
//import RealityKit
//
//class MotionProvider {
//    private let motionManager = CMMotionManager()
//    private var isStreaming = false // Simple control flag
//    
//    func quaternionStream() -> AsyncStream<simd_quatf> {
//        isStreaming = true // Set the streaming flag
//        return AsyncStream { continuation in
//            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
//                guard self.isStreaming, let motion = motion else {
//                    continuation.finish()
//                    return
//                }
//                
//                let attitude = motion.attitude
//                let quaternion = simd_quatf(ix: Float(attitude.quaternion.x),
//                                            iy: Float(attitude.quaternion.y),
//                                            iz: Float(attitude.quaternion.z),
//                                            r: Float(attitude.quaternion.w))
//                
//                continuation.yield(quaternion)
//            }
//        }
//    }
//    
//    // Implement the cancelStreaming method
//    func cancelStreaming() {
//        isStreaming = false
//        motionManager.stopDeviceMotionUpdates()
//    }
//}
//
//
