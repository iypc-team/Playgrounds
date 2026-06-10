// RealityKitView.swift
// 

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var model: AirplaneModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        let camera = PerspectiveCamera()
        camera.look(at: [0, 0, 0], from: [0, 4, 22], relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        if let entity = model.entity {
            let scaleFactor: Float = 4.0
            entity.scale = [scaleFactor * model.scale, scaleFactor * model.scale, scaleFactor * model.scale]
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            
            let directionalLight = DirectionalLight()
            directionalLight.light.intensity = 5000
            let lightAnchor = AnchorEntity(world: .zero)
            lightAnchor.addChild(directionalLight)
            arView.scene.addAnchor(lightAnchor)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let entity = model.entity {
            let scaleFactor: Float = 4.0
            entity.scale = [scaleFactor * model.scale, scaleFactor * model.scale, scaleFactor * model.scale]
            
            let yawQuat = simd_quatf(angle: Float(model.yaw.radians), axis: [0, 1, 0])
            let pitchQuat = simd_quatf(angle: Float(model.pitch.radians), axis: [1, 0, 0])
            let rollQuat = simd_quatf(angle: Float(model.roll.radians), axis: [0, 0, 1])
            entity.transform.rotation = yawQuat * pitchQuat * rollQuat
        }
    }
}
