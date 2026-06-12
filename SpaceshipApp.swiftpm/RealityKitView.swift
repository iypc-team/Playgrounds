// RealityKitView.swift
// Updated with fixed camera + clean model switching support

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: FighterModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        // === FIXED CAMERA SETUP ===
        let camera = PerspectiveCamera()
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 0, 25), relativeTo: nil)
        
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
        
        // Remove previous model anchor for clean switching
        if let oldAnchor = context.coordinator.modelAnchor {
            uiView.scene.removeAnchor(oldAnchor)
        }
        
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        uiView.scene.addAnchor(anchor)
        context.coordinator.modelAnchor = anchor
        
        // Scale
        let scaleFactor: Float = 4.0
        entity.scale = SIMD3<Float>(scaleFactor * model.scale, scaleFactor * model.scale, scaleFactor * model.scale)
        
        // Rotation
        let yawQuat   = simd_quatf(angle: Float(model.yaw.radians),   axis: SIMD3<Float>(0, 1, 0))
        let pitchQuat = simd_quatf(angle: Float(model.pitch.radians), axis: SIMD3<Float>(1, 0, 0))
        let rollQuat  = simd_quatf(angle: Float(model.roll.radians),  axis: SIMD3<Float>(0, 0, 1))
        
        entity.transform.rotation = yawQuat * pitchQuat * rollQuat
    }
    
    class Coordinator {
        var modelAnchor: AnchorEntity?
    }
}
