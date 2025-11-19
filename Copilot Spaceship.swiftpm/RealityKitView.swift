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
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(model)
            arView.scene.addAnchor(anchor)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Add update logic here if the entity changes (e.g., reload or modify the scene)
    }
}

