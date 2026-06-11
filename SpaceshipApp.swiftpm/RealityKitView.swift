// RealityKitView.swift

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: AirplaneModel  
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        let camera = PerspectiveCamera()
        camera.transform.translation = SIMD3<Float>(0, 0, 25)
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 0, 5), relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        // Light
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .gray
        directionalLight.light.intensity = 2500
        directionalLight.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
        let lightAnchor = AnchorEntity(world: .zero)
        lightAnchor.addChild(directionalLight)
        arView.scene.addAnchor(lightAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard let entity = model.entity else { return }
        
        // Add entity once if missing
        if entity.parent == nil {
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(entity)
            uiView.scene.addAnchor(anchor)
        }
        
        // Scale
        let scaleFactor: Float = 4.0
        entity.scale = SIMD3<Float>(scaleFactor * model.scale, scaleFactor * model.scale, scaleFactor * model.scale)
        
        // Rotation - Direct transform (stable, no conflicting move(to:))
        let yawQuat   = simd_quatf(angle: Float(model.yaw.radians),   axis: SIMD3<Float>(0, 1, 0))
        let pitchQuat = simd_quatf(angle: Float(model.pitch.radians), axis: SIMD3<Float>(1, 0, 0))
        let rollQuat  = simd_quatf(angle: Float(model.roll.radians),  axis: SIMD3<Float>(0, 0, 1))
        
        entity.transform.rotation = yawQuat * pitchQuat * rollQuat
    }
}
