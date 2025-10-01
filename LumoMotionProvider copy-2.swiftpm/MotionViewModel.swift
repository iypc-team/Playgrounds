// 
//

import SwiftUI
import CoreMotion

final class MotionViewModel: ObservableObject {
    @Published var quat = "—"
    
    func getStream() {
        print("getStream()")
        Task {
            do {
                for try await quat in quaternionStream(updateInterval: 1.0 / 120.0) {
                    // `quat` is a CMQuaternion (x, y, z, w)
                    print("Quaternion → x:\(quat.x) y:\(quat.y) z:\(quat.z) w:\(quat.w)")
                }
            } catch {
                // All errors flow here – you can differentiate them if you like
                if let motionErr = error as? MotionError {
                    print("Motion error: \(motionErr.localizedDescription)")
                } else {
                    print("Unexpected error: \(error)")
                }
            }
        }
    }
        
    func stopStream() {
        print("stopStream()")
    }
}
