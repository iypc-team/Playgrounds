// 
// 

import SwiftUI
import RealityKit
import ARKit

// Global variable to track axis (can be moved to a shared model if needed)
var currentAxisIndex = 0

struct RealityKitView: UIViewRepresentable {
    var entity: Entity?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        if let model = entity {
            model.scale = SIMD3<Float>(5.0, 5.0, 5.0)
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(model)
            arView.scene.addAnchor(anchor)
            
            // Add gestures if needed
            // arView.installGestures([.translation, .rotation, .scale], for: model)
            
            // Add light
            let directionalLight = DirectionalLight()
            directionalLight.light.intensity = 5000
            directionalLight.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
            
            let lightAnchor = AnchorEntity(world: .zero)
            lightAnchor.addChild(directionalLight)
            arView.scene.addAnchor(lightAnchor)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update logic here if needed
    }
    
    public func rotateModelCumulatively(_ model: Entity, by angleDegrees: Float = 22.5) async {
        await MainActor.run {
            print("func rotateModelCumulatively()")
            let axes: [[Float]] = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
            let axis = SIMD3<Float>(axes[currentAxisIndex])
            print(axis)
            let angleRadians = angleDegrees * .pi / 180
            print("angleRadians: \(angleRadians)\n")
            let rotation = simd_quatf(angle: angleRadians, axis: axis)
            model.transform.rotation *= rotation  // Apply cumulatively on main actor
            currentAxisIndex = (currentAxisIndex + 1) % 3  // Cycle through x, y, z
        }
        try? await Task.sleep(for: .seconds(1))  // Wait 1 second after rotation
    }
}

// Rotation function (call this from a button or gesture in your SwiftUI view)



//class RealityKitView2: UIViewRepresentable {
//    var entity: Entity?
//    var currentAxisIndex = 0  // Now mutable since it's a class
//    
//    // ... rest of the code ...
//    
//    func rotateModelCumulatively(by angleDegrees: Float = 22.5) async {
//        await MainActor.run {
//            let axes: [[Float]] = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
//            let axis = SIMD3<Float>(axes[currentAxisIndex])
//            let angleRadians = angleDegrees * .pi / 180
//            let rotation = simd_quatf(angle: angleRadians, axis: axis)
//            if let model = entity {
//                model.transform.rotation *= rotation
//            }
//            currentAxisIndex = (currentAxisIndex + 1) % 3
//        }
//        try? await Task.sleep(for: .seconds(1))
//    }
//}
