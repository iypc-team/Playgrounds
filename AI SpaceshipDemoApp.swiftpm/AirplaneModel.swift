//  
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 2.0
    @Published var rotationAngle: Float = 22.5  // New configurable property
    @Published var rotation: Angle = .zero
    
    var totalRotationAngle: Float = 0  // Still track for reference, but not limit
    
    func loadModel() {
        print("func loadModel()")
        Task {
            do {
                let loadedEntity = try await Entity.load(named: "Airplane-2")
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
        
        let stepAngle = rotationAngle  // Use configurable angle as step size
        var currentRotationAngle: Float = 0  // Local tracker for each axis
        
        // X-axis rotation
        print()
        let axisX = SIMD3<Float>(1, 0, 0)
        while currentRotationAngle < 360.0 {
            let angleRadians = stepAngle * .pi / 180
            await MainActor.run {
                let rotation = simd_quatf(angle: Float(angleRadians), axis: axisX)
                entity.transform.rotation *= rotation
            }
            currentRotationAngle += stepAngle
            print("X-axis rotation angle: \(currentRotationAngle)")
            // Add a small delay to make the rotation visible over time (adjust as needed)
            try? await Task.sleep(nanoseconds: 2000000000)  // 0.2 seconds
        }
        
        // Y-axis rotation
        print()
        let axisY = SIMD3<Float>(0, 1, 0)
        currentRotationAngle = 0
        while currentRotationAngle < 360.0 {
            let angleRadians = stepAngle * .pi / 180
            await MainActor.run {
                let rotation = simd_quatf(angle: Float(angleRadians), axis: axisY)
                entity.transform.rotation *= rotation
            }
            currentRotationAngle += stepAngle
            print("Y-axis rotation angle: \(currentRotationAngle)")
            // Add a small delay to make the rotation visible over time (adjust as needed)
            try? await Task.sleep(nanoseconds: 2000000000)  // 0.2 seconds
        }
        
        // Z-axis rotation
        print()
        let axisZ = SIMD3<Float>(0, 0, 1)
        currentRotationAngle = 0
        while currentRotationAngle < 360.0 {
            let angleRadians = stepAngle * .pi / 180
            await MainActor.run {
                let rotation = simd_quatf(angle: Float(angleRadians), axis: axisZ)
                entity.transform.rotation *= rotation
            }
            currentRotationAngle += stepAngle
            print("Z-axis rotation angle: \(currentRotationAngle)")
            // Add a small delay to make the rotation visible over time (adjust as needed)
            try? await Task.sleep(nanoseconds: 3000000000)  // 0.2 seconds
        }
        await self.resetRotation()
    }
    
    // New method: Reset rotation to initial state
    func resetRotation() async {
        guard let entity = entity else { return }
        await MainActor.run {
            entity.transform.rotation = .init()  // Reset to identity quaternion
            totalRotationAngle = 0
            print("\ntotalRotationAngle: \(totalRotationAngle)")
            print("Rotation reset\n")
        }
    }
}
