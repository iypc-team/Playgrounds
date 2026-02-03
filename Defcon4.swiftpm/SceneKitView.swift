//  SceneKitView.swift
//  attenuationStartDistance

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel = SceneModel()
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.scene?.background.contents = UIColor.black
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        
        configureFighterNode(in: scnView)
        
        return scnView
    }
    
    private func configureFighterNode(in scnView: SCNView) {
        guard let node = scene.rootNode.childNode(withName: "fighter", recursively: true) else {
            print("Warning: Fighter node not found in scene.")
            return
        }
        node.scale = sceneModel.fighterScale
        
        let sphere = SCNSphere(radius: 2.5)
        sphere
        
        let targetMaterial = SCNMaterial()
        targetMaterial.diffuse.contents = UIColor.red
        targetMaterial.lightingModel = .constant
        
        let targetNode = SCNNode()
        targetNode.geometry = sphere
        targetNode.position = SCNVector3(0, 50, 0)
        scene.rootNode.addChildNode(targetNode)
        
        let cone = SCNCone(topRadius: 0.2, bottomRadius: 10.0, height: 1024)
        let radarOffset = ((cone.height / 2) + 8.0)
        
        let radarMatreial = SCNMaterial()
        radarMatreial.diffuse.contents = UIColor.white
        radarMatreial.transparency = 0.1  // Sets opacity to 10%
        radarMatreial.lightingModel = .constant
        cone.materials = [radarMatreial]
        
        let radarNode = SCNNode(geometry: cone)
        radarNode.position = SCNVector3(0, -radarOffset, 0.25)
        // Add physics body (e.g., static for collision detection without movement)
        radarNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: cone, options: nil))
        node.addChildNode(radarNode)
        
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.position = SCNVector3(x: 0.0, y: -3.5, z: 5.0)
        cabinLightNode.light?.type = .omni
        cabinLightNode.light?.castsShadow = false
        cabinLightNode.light?.attenuationStartDistance = 1.0
        cabinLightNode.light?.attenuationEndDistance = 5.0
        cabinLightNode.light?.color = sceneModel.cabinLightColor
        cabinLightNode.light?.intensity = sceneModel.cabinLightIntensity
        node.addChildNode(cabinLightNode)
        
        let engineLightNode = SCNNode()
        engineLightNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        engineLightNode.light = SCNLight()
        engineLightNode.light?.type = .omni
        engineLightNode.light?.castsShadow = false
        engineLightNode.light?.attenuationStartDistance = 1.0
        engineLightNode.light?.attenuationEndDistance = 5.0
        engineLightNode.light?.color = UIColor.green
        engineLightNode.light?.intensity = sceneModel.engineLightIntensity
        node.addChildNode(engineLightNode)
        
        let engineLightNode2 = SCNNode()
        engineLightNode2.position = SCNVector3(x: 0.0, y: 3.0, z: 0.0)
        engineLightNode2.light = SCNLight()
        engineLightNode2.light?.type = .omni
        engineLightNode2.light?.castsShadow = false
        engineLightNode2.light?.attenuationStartDistance = 1.0
        engineLightNode2.light?.attenuationEndDistance = 5.0
        engineLightNode2.light?.color = UIColor.green
        engineLightNode2.light?.intensity = sceneModel.engineLightIntensity
        node.addChildNode(engineLightNode2)
        
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Re-scale fighter and update light if sceneModel changed
        configureFighterNode(in: uiView)
    }
}

