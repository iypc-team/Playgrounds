// MotionModel
//  

import CoreMotion
import Foundation

// Model for handling device motion
class MotionModel {
    private let motionManager = CMMotionManager()
    
    // This method returns an AsyncThrowingStream of quaternion data
    func getAttitudeStream() -> AsyncThrowingStream<CMQuaternion, Error> {
        AsyncThrowingStream { continuation in
            // Check if device motion is available
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(domain: "MotionManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]))
                return
            }
            
            // Start receiving device motion data
            motionManager.deviceMotionUpdateInterval = 1 / 60.0 // 60 Hz updates
            motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                // Yield the quaternion from the motion data
                if let motion = motionData {
                    let quaternion = motion.attitude.quaternion
                    continuation.yield(quaternion)
                }
            }
            
            // Stop updates when the stream is terminated
            continuation.onTermination = { _ in
                self.motionManager.stopDeviceMotionUpdates()
            }
        }
    }
}

