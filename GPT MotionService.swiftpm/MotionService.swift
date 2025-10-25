//  Encapsulate CoreMotion
//  

import CoreMotion

class MotionService {
    public let motionManager = CMMotionManager()
    
    func isMotionActive() -> Bool {
        print("func isMotionActive()")
        return self.motionManager.isDeviceMotionActive
    }
    
    func startMotionUpdates(handler: @escaping (CMQuaternion?) -> Void) {
        print("func startMotionUpdates()\n ")
        guard motionManager.isDeviceMotionAvailable else {
            handler(nil)
            return
        }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.deviceMotionUpdateInterval = 2.0
        motionManager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical,
            to: .main
        ) { motionData, _ in
            handler(motionData?.attitude.quaternion)
        }
    }
    
    func stopMotionUpdates() {
        print("func stopDeviceMotionUpdates()\n ")
        motionManager.stopDeviceMotionUpdates()
    }
}
