//  
//  

import CoreMotion

class MotionService {
    private let motionManager = CMMotionManager()
    
    func startMotionUpdates(handler: @escaping (CMQuaternion?) -> Void) {
        print("func startMotionUpdates() ")
        guard motionManager.isDeviceMotionAvailable else {
            handler(nil)
            return
        }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.deviceMotionUpdateInterval = 5.0
        motionManager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical,
            to: .main
        ) { motionData, _ in
            handler(motionData?.attitude.quaternion)
        }
    }
    
    func stopMotionUpdates() {
        print("func stopDeviceMotionUpdates() ")
        motionManager.stopDeviceMotionUpdates()
    }
}
