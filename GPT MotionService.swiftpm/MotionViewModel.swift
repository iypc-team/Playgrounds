// 
// 

import Foundation
import CoreMotion
import Combine

class MotionViewModel: ObservableObject {
    private var motionService = MotionService()
    @Published var quaternion: CMQuaternion?
    
    func start() {
        print("func start()  ")
        motionService.startMotionUpdates { [weak self] quaternion in
            DispatchQueue.main.async {
                self?.quaternion = quaternion
                print("\(quaternion!)\n")
            }
        }
    }
    
    func stop() {
        print("func stop()  ")
        motionService.stopMotionUpdates()
    }
}
