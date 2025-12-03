// 
// 

import SwiftUI
import RealityKit
import ARKit  // Required for ARView

struct RealityKitView: UIViewRepresentable {
    var entity: Entity?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR  // Disable AR tracking for non-AR 3D display
        
        if let model = entity {
            model.scale = SIMD3<Float>(5.0, 5.0, 5.0)
            print(".components.count: \(model.components.count)")
            print(".components: \(model.components)")
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(model)
            arView.scene.addAnchor(anchor)
            
            // Add this line here to enable gestures
//            arView.installGestures([.translation, .rotation, .scale], for: model)
            
            // Add a directional light to illuminate the scene
            let directionalLight = DirectionalLight()
            directionalLight.light.intensity = 5000  // Adjust intensity as needed
            directionalLight.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])  // Point downward slightly
            
            let lightAnchor = AnchorEntity(world: .zero)
            lightAnchor.addChild(directionalLight)
            arView.scene.addAnchor(lightAnchor)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Add update logic here if the entity changes (e.g., reload or modify the scene)
    }
}

