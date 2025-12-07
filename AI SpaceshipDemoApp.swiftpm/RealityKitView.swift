//  
// 

import SwiftUI
import RealityKit

//var totalRotationAngle: Float = 0

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: AirplaneModel  
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        if let entity = model.entity {
            entity.scale = SIMD3<Float>(4.0 * model.scale, 4.0 * model.scale, 4.0 * model.scale)  // Apply scale
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            
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
        if let entity = model.entity {
            entity.scale = SIMD3<Float>(4.0 * model.scale, 4.0 * model.scale, 4.0 * model.scale)  // Update scale
        }
    }
}


