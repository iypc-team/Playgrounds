// quaternion
//  

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private let motionProvider = CMMotionManager()
    private let hertz = 1.0
    var queue = OperationQueue()
    
    var timer = Timer()
    
    @Published var w = 0.0
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    
    @Published var roll = 0.0
    @Published var pitch = 0.0
    @Published var yaw = 0.0
    
    init() {
//        print("queue.name: \(queue.name!)")
        queue.name = "MotionQueue"
        print("queue.name: \(queue.name!)")
        queue.qualityOfService = .background
        print("queue.qualityOfService: \(queue.qualityOfService)")
        queue.maxConcurrentOperationCount = 8
        print("queue.maxConcurrentOperationCount: \(queue.maxConcurrentOperationCount)\n")
        
    }
    
    func startDeviceMotion() {
        if motionProvider.isDeviceMotionAvailable && !motionProvider.isDeviceMotionActive {
            self.motionProvider.deviceMotionUpdateInterval = 1.0 / hertz
            self.motionProvider.showsDeviceMovementDisplay = true
            self.motionProvider.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the motionProvider data.
            self.timer = Timer(fire: Date(), interval: (1.0 / hertz), repeats: true,
                               block: { (timer) in
                if let data = self.motionProvider.deviceMotion {
                    // Get the attitude relative to the magnetic north reference frame.
                    self.w = data.attitude.quaternion.w
                    self.x = data.attitude.quaternion.x
                    self.y = data.attitude.quaternion.y
                    self.z = data.attitude.quaternion.z
                    
                    self.roll = data.attitude.roll
                    self.pitch = data.attitude.pitch
                    self.yaw = data.attitude.yaw
                    
                    // Use the motionProvider data in your app.
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.main.add(self.timer, forMode: RunLoop.Mode.default)
        }
    }
    
    func startQueuedUpdates() {
        print("func startQueuedUpdates()")
        if motionProvider.isDeviceMotionAvailable {
            self.motionProvider.deviceMotionUpdateInterval = 1.0 / hertz
            self.motionProvider.showsDeviceMovementDisplay = true
            self.motionProvider.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, 
                                                         to: self.queue, withHandler: { (data, error) in
                // Make sure the data is valid before accessing it.
                if let validData = data {
                    // Get the attitude relative to the magnetic north reference frame. 
                    self.w = validData.attitude.quaternion.w
                    self.x = validData.attitude.quaternion.x
                    self.y = validData.attitude.quaternion.y
                    self.z = validData.attitude.quaternion.z
                    
                    self.roll = validData.attitude.roll
                    self.pitch = validData.attitude.pitch
                    self.yaw = validData.attitude.yaw
                    
                    print(validData)
                    print("w: \(self.w)")
                    print("x: \(self.x)")
                    print("y: \(self.y)")
                    print("z: \(self.z)")
                    
                    print("xRoll: \(self.roll)")
                    print("yPitch: \(self.pitch)")
                    print("zYaw: \(self.yaw)\n")
                    // Use the motionProvider data in your app.
                }
            })
        }
    }
    
    func stopMotionUpdates() {
        print("func stopMotionUpdates")
        if motionProvider.isDeviceMotionActive {
            motionProvider.stopDeviceMotionUpdates()
            //            self.queue
        }
    }
    
    
} 


//. 

