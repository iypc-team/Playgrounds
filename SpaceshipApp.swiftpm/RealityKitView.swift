// RealityKitView.swift
// Fixed coordinator + consistent FighterModel + debug prints
// iOS 16.6 compliant

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
        print("✅ ARView created (nonAR mode)")
        
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
        guard let entity = model.entity else { 
            print("⚠️ updateUIView: No entity available yet")
            return 
        }
        
        print("🔄 updateUIView for model: '\(model.currentModelName)'")
        
        // Clean previous anchor
        if let oldAnchor = context.coordinator.modelAnchor {
            uiView.scene.removeAnchor(oldAnchor)
            print("🗑️ Removed previous anchor")
        }
        
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        uiView.scene.addAnchor(anchor)
        context.coordinator.modelAnchor = anchor
        print("📍 New anchor added")
        
        // Apply transforms
        let s = Float(model.scale)
        entity.scale = SIMD3<Float>(s, s, s)
        
        let yawQ   = simd_quatf(angle: Float(model.yaw.radians),   axis: [0, 1, 0])
        let pitchQ = simd_quatf(angle: Float(model.pitch.radians), axis: [1, 0, 0])
        let rollQ  = simd_quatf(angle: Float(model.roll.radians),  axis: [0, 0, 1])
        
        entity.transform.rotation = yawQ * pitchQ * rollQ
        
        print("✅ Applied transform → Scale: \(s)x | Yaw: \(model.yaw.degrees)° Pitch: \(model.pitch.degrees)° Roll: \(model.roll.degrees)°")
    }
    
    class Coordinator {
        var modelAnchor: AnchorEntity?
    }
}
