//  
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 1.0
    @Published var rotationAngle: Float = 22.5  // New configurable property
    
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
            let angleRadians = rotationAngle * .pi / 180  // Use configurable angle
            let rotation = simd_quatf(angle: Float(angleRadians), axis: axis)
            entity.transform.rotation *= rotation
            totalRotationAngle += rotationAngle  // Update with configurable angle
            print("totalRotationAngle: \(totalRotationAngle)")
            if totalRotationAngle >= 360.0 { totalRotationAngle = 0.0 }
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
}
