// 
// 

import SwiftUI
import RealityKit

struct AirplaneARView: UIViewRepresentable {
    @ObservedObject var viewModel: AirplaneViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR  // Virtual camera, no AR tracking
        arView.environment.lighting.intensityExponent = 1.0  // Basic lighting adjustment
        
        // Load and add model
        if viewModel.airplaneEntity == nil {
            viewModel.loadModel()
        }
        
        // Add lighting
        let light = DirectionalLight()
        light.light.intensity = 3000
        light.position = [2, 2, 2]
        light.look(at: .zero, from: light.position, relativeTo: nil)
        arView.scene.addAnchor(light as! HasAnchoring)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let airplane = viewModel.airplaneEntity {
            airplane.transform = viewModel.transform
            // Add to scene if not already
            if !uiView.scene.anchors.contains(where: { $0.children.contains(airplane) }) {
                let anchor = AnchorEntity(world: .zero)
                anchor.addChild(airplane)
                uiView.scene.addAnchor(anchor)
            }
        }
    }
}

