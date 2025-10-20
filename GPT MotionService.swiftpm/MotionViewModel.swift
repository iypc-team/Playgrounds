//  
//  

import Foundation
import CoreMotion
import Combine

class MotionViewModel: ObservableObject {
    @Published var quaternion: CMQuaternion?
    private var motionService = MotionService()
    
    func start() {
        print("func start()  ")
        motionService.startMotionUpdates { [weak self] quaternion in
            DispatchQueue.main.async {
                self?.quaternion = quaternion
            }
        }
    }
    
    func stop() {
        print("func stop()  ")
        motionService.stopMotionUpdates()
    }
}
