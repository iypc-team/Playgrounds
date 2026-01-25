//  
//  

import Foundation
import CoreMotion

final class MotionViewModel: ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 0.5
    }
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device motion not available")
            return
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self,
                  let attitude = data?.attitude,
                  error == nil else { return }
            
            self.roll = attitude.roll
            self.pitch = attitude.pitch
            self.yaw = attitude.yaw
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
