// quaternion
//  
//  MotionManager  09/13/2025-2

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private let motionProvider = CMMotionManager()
    private let hertz = 1.0
    var queue = OperationQueue()
    var timer = Timer()
    
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    
    @Published var roll = 0.0
    @Published var pitch = 0.0
    @Published var yaw = 0.0
    
    init() {
        queue.name = "MotionQueue"
        print("queue.name: \(queue.name!)")
        queue.qualityOfService = .background
        print("queue.qualityOfService: \(queue.qualityOfService)")
        queue.maxConcurrentOperationCount = 8
        print("queue.maxConcurrentOperationCount: \(queue.maxConcurrentOperationCount)")
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
                    self.x = data.attitude.pitch
                    self.y = data.attitude.roll
                    self.z = data.attitude.yaw
                    
                    // Use the motionProvider data in your app.
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.main.add(self.timer, forMode: RunLoop.Mode.default)
        }
    }
    
    func startQueuedUpdates() {
        if motionProvider.isDeviceMotionAvailable {
            self.motionProvider.deviceMotionUpdateInterval = 1.0 / hertz
            self.motionProvider.showsDeviceMovementDisplay = true
            self.motionProvider.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, 
                                                         to: self.queue, withHandler: { (data, error) in
                // Make sure the data is valid before accessing it.
                if let validData = data {
                    // Get the attitude relative to the magnetic north reference frame. 
                    self.roll = validData.attitude.roll
                    self.pitch = validData.attitude.pitch
                    self.yaw = validData.attitude.yaw
                    print(validData)
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

