// 
// 

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: AirplaneModel  
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        let camera = PerspectiveCamera()
        camera.transform.translation = SIMD3<Float>(0, 5, 5)
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 0, 5.0), relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        if let entity = model.entity {
            let scaleFactor: Float = 4.0  // Define as Float to avoid type issues
            entity.scale = SIMD3<Float>(scaleFactor * model.scale, scaleFactor * model.scale, scaleFactor * model.scale)
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            
            let directionalLight = DirectionalLight()
            directionalLight.light.intensity = 5000
            directionalLight.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])  // Note: .pi is Double, but this works in context
            let lightAnchor = AnchorEntity(world: .zero)
            lightAnchor.addChild(directionalLight)
            arView.scene.addAnchor(lightAnchor)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let entity = model.entity {
            let scaleFactor: Float = 4.0
            entity.scale = SIMD3<Float>(scaleFactor * model.scale, scaleFactor * model.scale, scaleFactor * model.scale)
            
            // Unified rotation: Combine yaw, pitch, roll into a quaternion
            let yawQuat = simd_quatf(angle: Float(model.yaw.radians), axis: SIMD3<Float>(0, 1, 0))
            let pitchQuat = simd_quatf(angle: Float(model.pitch.radians), axis: SIMD3<Float>(1, 0, 0))
            let rollQuat = simd_quatf(angle: Float(model.roll.radians), axis: SIMD3<Float>(0, 0, 1))
            entity.transform.rotation = yawQuat * pitchQuat * rollQuat  // Order: yaw first, then pitch, then roll
        }
    }
}
