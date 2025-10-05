//  MotionViewModel
//  

import Foundation
import Combine

class MotionViewModel: ObservableObject {
    private var model: MotionModel
    private var cancellables = Set<AnyCancellable>()
    
    // The published property for the View to observe
    @Published var quaternion: CMQuaternion?
    
    init(model: MotionModel = MotionModel()) {
        self.model = model
        // Start receiving attitude data
        startListeningForMotionData()
    }
    
    private func startListeningForMotionData() {
        // Launch an async task to listen to motion data
        Task {
            do {
                let attitudeStream = model.getAttitudeStream()
                for try await quat in attitudeStream {
                    // Update the quaternion data
                    DispatchQueue.main.async {
                        self.quaternion = quat
                    }
                }
            } catch {
                // Handle error (e.g., show a message to the user)
                DispatchQueue.main.async {
                    self.quaternion = nil
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

