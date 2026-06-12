// RealityKitView.swift
// Updated with AirplaneModel + clean model switching (iOS 16.6)

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: AirplaneModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        // Fixed camera
        let camera = PerspectiveCamera()
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 0, 22), relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        // Lighting
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .white
        directionalLight.light.intensity = 3000
        directionalLight.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
        
        let lightAnchor = AnchorEntity(world: .zero)
        lightAnchor.addChild(directionalLight)
        arView.scene.addAnchor(lightAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard let entity = model.entity else { return }
        
        // Clean model switching
        if let oldAnchor = context.coordinator.modelAnchor {
            uiView.scene.removeAnchor(oldAnchor)
        }
        
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        uiView.scene.addAnchor(anchor)
        context.coordinator.modelAnchor = anchor
        
        // Apply transforms
        let s = Float(model.scale)
        entity.scale = SIMD3<Float>(s, s, s)
        
        let yawQ   = simd_quatf(angle: Float(model.yaw.radians),   axis: [0, 1, 0])
        let pitchQ = simd_quatf(angle: Float(model.pitch.radians), axis: [1, 0, 0])
        let rollQ  = simd_quatf(angle: Float(model.roll.radians),  axis: [0, 0, 1])
        
        entity.transform.rotation = yawQ * pitchQ * rollQ
    }
    
    class Coordinator {
        var modelAnchor: AnchorEntity?
    }
}
