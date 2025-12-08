//  
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 3.0
    @Published var rotationAngle: Float = 90.0  // New configurable property
    
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
        let axis = SIMD3<Float>(1, 0, 0)
        let stepAngle = rotationAngle  // Use configurable angle as step size
        while totalRotationAngle < 360.0 {
            await MainActor.run {
                let angleRadians = stepAngle * .pi / 180
                let rotation = simd_quatf(angle: Float(angleRadians), axis: axis)
                entity.transform.rotation *= rotation
                totalRotationAngle += stepAngle
                print("totalRotationAngle: \(totalRotationAngle)")
            }
            // Add a small delay to make the rotation visible over time (adjust as needed)
            try? await Task.sleep(nanoseconds: 2000000000)  // 0.01 seconds
        }
        totalRotationAngle = 0.0
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
