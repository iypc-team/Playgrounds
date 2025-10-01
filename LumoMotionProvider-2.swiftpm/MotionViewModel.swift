// 
//

import SwiftUI
import CoreMotion
final class MotionViewModel: ObservableObject {
    @Published var quaternionString = "—"
    private let provider = MotionProvider()
    private var task: Task<Void, Never>? = nil
    
    func start() {
        task = Task {
            for await quat in provider.quaternionStream() {
                await MainActor.run {
                    quaternionString = String(
                        format: "(%.3f, %.3f, %.3f, %.3f)",
                        quat.x, quat.y, quat.z, quat.w
                    )
                }
            }
        }
    }
    
    func stop() {
        task?.cancel()
        task = nil
    }
}
