import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    var roll = 0.0
    var pitch = 0.0
    var yaw = 0.0
    
    init() {
        // motionManager.startDeviceMotionUpdates(to: <#T##OperationQueue#>, withHandler: <#T##CMDeviceMotionHandler##CMDeviceMotionHandler##(CMDeviceMotion?, Error?) -> Void#>)
        motionManager.startDeviceMotionUpdates(to: .main, withHandler: {
            [weak self] motion, error  in guard let self=self, let motion=motion else {
                return
            }
            self.pitch = motion.attitude.pitch
            self.roll = motion.attitude.roll
            self.yaw=motion.attitude.yaw
            
        })
    }
}

