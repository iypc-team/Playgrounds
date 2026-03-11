// SceneViewModel.swift
//  
// Handles scene creation, configuration, and business logic.
//  

import SwiftUI
import SceneKit
import QuartzCore
import GLKit

class SceneViewModel: ObservableObject {
    @Published var scene: SCNScene
    
    private let model = SceneModel()
    
    init() {
        scene = SCNScene(named: model.shipName + ".scn")!
        setupScene()
    }
    
    private func setupScene() {
        // Add camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = model.camera.position
        cameraNode.camera?.automaticallyAdjustsZRange = model.camera.automaticallyAdjustsZRange
        cameraNode.look(at: model.camera.lookAt)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add ambient lights
        for lightConfig in model.ambientLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = lightConfig.type
            lightNode.light!.color = lightConfig.color
            lightNode.position = lightConfig.position
            scene.rootNode.addChildNode(lightNode)
        }
        
        // Add engine lights
        for lightConfig in model.engineLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = lightConfig.type
            lightNode.light!.color = lightConfig.color
            lightNode.light!.intensity = lightConfig.intensity!
            lightNode.light!.castsShadow = lightConfig.castsShadow
            lightNode.light!.attenuationEndDistance = lightConfig.attenuationEndDistance!
            lightNode.position = lightConfig.position
            // Note: In original, these are added to ship later
        }
        
        // Add cabin light
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.light!.type = model.cabinLight.type
        cabinLightNode.light!.color = model.cabinLight.color
        cabinLightNode.light!.intensity = model.cabinLight.intensity!
        cabinLightNode.light!.castsShadow = model.cabinLight.castsShadow
        cabinLightNode.light!.attenuationEndDistance = model.cabinLight.attenuationEndDistance!
        cabinLightNode.position = model.cabinLight.position
        
        // Create plane
        let plane = SCNPlane(width: model.plane.width, height: model.plane.height)
        plane.firstMaterial?.isDoubleSided = model.plane.isDoubleSided
        plane.firstMaterial?.diffuse.contents = model.plane.materialColor
        plane.firstMaterial?.fresnelExponent = model.plane.fresnelExponent
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = model.plane.position
        planeNode.runAction(SCNAction.rotate(by: model.plane.rotationAngle, around: SCNVector3(1, 0, 0), duration: 0))
        
        // Retrieve and configure ship
        let ship = scene.rootNode.childNode(withName: model.shipName, recursively: true)!
        ship.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        ship.geometry?.firstMaterial?.isDoubleSided = true
        
        // Add children to ship
        ship.addChildNode(planeNode)
        ship.addChildNode(cabinLightNode)
        // Add engine lights to ship (assuming from original context)
        for lightConfig in model.engineLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = lightConfig.type
            lightNode.light!.color = lightConfig.color
            lightNode.light!.intensity = lightConfig.intensity!
            lightNode.light!.castsShadow = lightConfig.castsShadow
            lightNode.light!.attenuationEndDistance = lightConfig.attenuationEndDistance!
            lightNode.position = lightConfig.position
            ship.addChildNode(lightNode)
        }
        
        // Debug prints (kept for consistency, can be removed)
        print("\nship.pivot\n", ship.pivot)
        print("ship.orientation: ", ship.orientation)
    }
}
