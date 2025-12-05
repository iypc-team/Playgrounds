//  
// bullshit
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 1.0  // Add for scaling
    
    func loadModel() {
        Task {
            do {
                let loadedEntity = try await Entity.load(named: "Airplane")
                DispatchQueue.main.async {
                    self.entity = loadedEntity
                }
            } catch {
                print("Error loading model: \(error.localizedDescription)")
            }
        }
    }
    
    func rotateModel() async {
        guard let entity = entity else { return }
        await MainActor.run {
            let axis = SIMD3<Float>(1, 0, 0)
            if totalRotationAngle + 45.0 <= 360.0 {
                let angleRadians = 45.0 * .pi / 180
                let rotation = simd_quatf(angle: Float(angleRadians), axis: axis)
                entity.transform.rotation *= rotation
                totalRotationAngle += 45.0
                print("totalRotationAngle: \(totalRotationAngle)")
            }
        }
    }
}

