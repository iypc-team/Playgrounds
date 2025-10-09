//  
//  

import Combine
import SwiftUI

@MainActor
final class MotionViewModel: ObservableObject {
    @Published var quaternion = Quaternion(w: 1, x: 0, y: 0, z: 0)   // identity rotation
    
    private let service = MotionService()
    private var task: Task<Void, Never>? = nil
    
    func start() {
        // Cancel any previous task first
        task?.cancel()
        task = Task {
            do {
                for try await q in service.quaternionStream() {
                    // UI updates must happen on the main thread
                    self.quaternion = q
                }
            } catch {
                // Handle errors (e.g., show an alert)
                print("Motion error:", error)
            }
        }
    }
    
    func stop() {
        task?.cancel()
        task = nil
    }
}
