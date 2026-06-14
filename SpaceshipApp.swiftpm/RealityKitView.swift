// Updated RealityKitView.swift
// - Fixed 'AmbientLight' scope error
// - Uses correct iOS 16.6+ skybox API
// - Clean and reliable lighting setup

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
        
        // === Camera ===
        let camera = PerspectiveCamera()
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 0, Constants.cameraDistance), relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        // === Skybox + Environment (Correct iOS 16.6+ API) ===
        if let skyboxResource = try? EnvironmentResource.load(named: "space_nebula") {
            arView.environment.lighting.resource = skyboxResource
            arView.environment.background = .skybox(skyboxResource)
            arView.environment.lighting.intensityExponent = Constants.skyboxIntensityExponent
        } else {
            arView.backgroundColor = .black
        }
        
        // === Main Directional Light ===
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .white
        directionalLight.light.intensity = Constants.directionalLightIntensity
        directionalLight.orientation = simd_quatf(angle: Constants.lightTiltAngleRadians, axis: [1, 0, 0])
        
        let lightAnchor = AnchorEntity(world: .zero)
        lightAnchor.addChild(directionalLight)
        arView.scene.addAnchor(lightAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard let entity = model.entity else { return }
        
        // Reuse anchor via Coordinator
        if let existingAnchor = context.coordinator.modelAnchor {
            existingAnchor.children.forEach { $0.removeFromParent() }
            existingAnchor.addChild(entity)
        } else {
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(entity)
            uiView.scene.addAnchor(anchor)
            context.coordinator.modelAnchor = anchor
        }
        
        // Apply scale and rotation
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
