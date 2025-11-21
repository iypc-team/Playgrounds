// 
// 

import SwiftUI
import RealityKit

class AirplaneViewModel: ObservableObject {
    @Published var airplaneEntity: ModelEntity?
    @Published var transform: Transform = .identity
    
    func loadModel() async {
        if let entity = try? await ModelEntity(named: "Airplane") {
            entity.generateCollisionShapes(recursive: true)  // Enables gesture interactions
            await MainActor.run {
                self.airplaneEntity = entity
            }
        }
    }
    
    func updateTransform(with gesture: DragGesture.Value) {
        // Simple drag example; expand for rotate/scale as needed
        transform.translation.x += Float(gesture.translation.width) * 0.01
        transform.translation.y -= Float(gesture.translation.height) * 0.01
    }
}

