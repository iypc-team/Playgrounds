// 
// 

import SwiftUI
import RealityKit

struct RealityView: UIViewRepresentable {
    // The ViewModel
    let viewModel: AirplaneViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Add the Airplane Entity to the AR scene if it exists
        if let airplaneEntity = viewModel.airplaneEntity {
            let anchor = AnchorEntity(world: [0, 0, -1]) // Adjust anchor position as needed
            anchor.addChild(airplaneEntity)
            arView.scene.addAnchor(anchor)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Handle updates when needed
    }
}
