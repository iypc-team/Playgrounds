//  SceneKitView.swift
//  

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel
    
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
            // Skip configuration if fighter node not found (no warning logged)
            return
        }
        node.scale = sceneModel.fighterScale
        
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.position = SCNVector3(x: 0.0, y: -5.0, z: 0.0)
        cabinLightNode.light?.type = .omni
        cabinLightNode.light?.castsShadow = false
        cabinLightNode.light?.attenuationStartDistance = 1.0
        cabinLightNode.light?.attenuationEndDistance = 5.0
        cabinLightNode.light?.color = sceneModel.cabinLightColor
        cabinLightNode.light?.intensity = sceneModel.omniLightIntensity  // Use model property
        //        print("cabinLightNode: \(String(describing: cabinLightNode.light?.intensity)) ")
        
        node.addChildNode(cabinLightNode)
        
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        engineLightNode.light?.type = .omni
        engineLightNode.light?.castsShadow = false
        engineLightNode.light?.attenuationStartDistance = 1.0
        engineLightNode.light?.attenuationEndDistance = 5.0
        engineLightNode.light?.color = sceneModel.engineLightColor  // Use model property
        engineLightNode.light?.intensity = sceneModel.omniLightIntensity  // Use model property
        //        print("engineLightNode: \(engineLightNode.description)\n ")
        
        node.addChildNode(engineLightNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the scene if it has changed
        uiView.scene = scene
        // Ensure background is always black, overriding any scene file settings
        uiView.scene?.background.contents = UIColor.black
        // Re-scale fighter and update lights if sceneModel changed
        configureFighterNode(in: uiView)
    }
}

