//  
// 

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: AirplaneModel  
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        // Create and position a custom camera for non-AR mode
        let camera = PerspectiveCamera()
        camera.transform.translation = SIMD3<Float>(0, 1, 10)  // Adjust position as needed (e.g., 10 units back)
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 1, 10), relativeTo: nil)  // Look at origin
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
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


