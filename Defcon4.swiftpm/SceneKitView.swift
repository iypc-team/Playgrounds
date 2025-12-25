// 
// 

import SwiftUI
import SceneKit
import os


struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Defcon4", category: "SceneKitView")
    
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
            // Use print for warnings instead of Logger
            print("Warning: Fighter node not found in scene.")
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
        cabinLightNode.light?.intensity = 6000
//        print("cabinLightNode: \(String(describing: cabinLightNode.light?.intensity)) ")
        
        node.addChildNode(cabinLightNode)
        
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        engineLightNode.light?.type = .omni
        engineLightNode.light?.castsShadow = false
        engineLightNode.light?.attenuationStartDistance = 1.0
        engineLightNode.light?.attenuationEndDistance = 5.0
        engineLightNode.light?.color = UIColor.green
        engineLightNode.light?.intensity = 6000 
//        print("engineLightNode: \(engineLightNode.description)\n ")
        
        node.addChildNode(engineLightNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Use logger for info-level logging instead of print
        logger.info("Updating SceneKitView with sceneModel changes.")
        Logger().info("Updating SceneKitView with sceneModel changes.")
        // Re-scale fighter and update light if sceneModel changed
        configureFighterNode(in: uiView)
    }
}

