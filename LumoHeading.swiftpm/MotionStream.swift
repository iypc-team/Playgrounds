//// 
//// 
//// 
//
//import CoreMotion
//import Foundation
//
///// A thin async‑sequence that yields the latest `CMDeviceMotion` objects.
///// Errors are propagated via `AsyncThrowingStream`.
//struct MotionStream {
//    private let manager = CMMotionManager()
//    private let updateInterval: TimeInterval
//    
//    init(updateInterval: TimeInterval = 1.0 / 60.0) {
//        self.updateInterval = updateInterval
//    }
//    
//    /// Returns an async sequence that produces motion data until cancelled or an error occurs.
//    func makeAsyncIterator() -> AsyncThrowingStream<CMDeviceMotion, Error>.Iterator {
//        AsyncThrowingStream { continuation in
//            // MARK: – Cancellation handling
//            continuation.onTermination = { @Sendable _ in
//                manager.stopDeviceMotionUpdates()
//            }
//            
//            // MARK: – Start updates
//            guard manager.isDeviceMotionAvailable else {
//                continuation.finish(throwing: NSError(
//                    domain: "MotionStream",
//                    code: 1,
//                    userInfo: [NSLocalizedDescriptionKey: "Device‑motion not available"]
//                ))
//                return
//            }
//            
//            manager.deviceMotionUpdateInterval = updateInterval
//            manager.startDeviceMotionUpdates(to: .main) { motion, error in
//                if let error = error {
//                    continuation.finish(throwing: error)
//                    return
//                }
//                if let motion = motion {
//                    continuation.yield(motion)
//                }
//            }
//        }.makeAsyncIterator()
//    }
//}
//
