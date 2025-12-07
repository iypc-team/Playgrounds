//  
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 1.0
    
    var totalRotationAngle: Float = 0  // Still track for reference, but not limit
    
    func loadModel() {
        print("func loadModel()")
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
        print("func rotateModel()")
        guard let entity = entity else { return }
        await MainActor.run {
            let axis = SIMD3<Float>(1, 0, 0)
            let angleRadians = 45.0 * .pi / 180
            let rotation = simd_quatf(angle: Float(angleRadians), axis: axis)
            entity.transform.rotation *= rotation
            totalRotationAngle += 45.0  // Optional: Keep tracking for UI feedback
            print("totalRotationAngle: \(totalRotationAngle)")
            if totalRotationAngle == 360.0 { totalRotationAngle = 0.0
                print("totalRotationAngle: \(totalRotationAngle)")
            }
        }
    }
    
    // New method: Reset rotation to initial state
    func resetRotation() async {
        guard let entity = entity else { return }
        await MainActor.run {
            entity.transform.rotation = .init()  // Reset to identity quaternion
            totalRotationAngle = 0
            print("Rotation reset")
        }
    }
//    if totalRotationAngle == 360.0 {
//        resetRotation()
//    }
}
