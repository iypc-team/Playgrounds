// MotionViewModel
// 

import Combine
import CoreMotion
import SwiftUI

@MainActor  // Published for SwiftUI views
final class MotionViewModel: ObservableObject {
    
    @Published var quaternion: CMQuaternion = CMQuaternion(x: 0, y: 0, z: 0, w: 1)
    
    private let service = MotionService()
    private var task: Task<Void, Never>?   // Holds the async loop
    
    // MARK: Public API
    func start() {
        print("func start()")
        // Cancel any existing task first
        task?.cancel()
        
        task = Task {
            do {
                // Consume the async stream
                for try await quat in service.quaternionStream() {
                    // UI updates must happen on the main actor
                    self.quaternion = quat
                }
            } catch {
                // Handle errors (e.g., show an alert)
                print("Motion error:", error.localizedDescription)
            }
        }
    }
    
    func stop() {
        print("func stop()")
        task?.cancel()
        task = nil
    }
}
