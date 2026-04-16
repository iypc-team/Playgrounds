//  SceneKitView.swift

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
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = sceneModel.antialiasingMode
        
        // Force our programmatic camera so embedded .scn cameras don't
        // override the auto-framed viewpoint
        if let appCamera = scene.rootNode.childNode(withName: "appCamera", recursively: true) {
            scnView.pointOfView = appCamera
        }
        
        configureSceneNode(in: scnView)
        
        return scnView
    }
    
    private func configureSceneNode(in scnView: SCNView) {
        // Try the "fighter" node first (for fighter scenes)
        if let fighterNode = scene.rootNode.childNode(withName: "fighter", recursively: true) {
            configureFighterLights(on: fighterNode)
            return
        }
        
        // For ALL other scenes (like smooth_ship.scn), find the first node
        // with geometry and apply generic lighting to it
        if let firstGeometryNode = findFirstNodeWithGeometry(in: scene.rootNode) {
            configureGenericLights(on: firstGeometryNode)
        }
    }
    
    /// Recursively finds the first child node that has geometry
    private func findFirstNodeWithGeometry(in node: SCNNode) -> SCNNode? {
        if node.geometry != nil {
            return node
        }
        for child in node.childNodes {
            if let found = findFirstNodeWithGeometry(in: child) {
                return found
            }
        }
        return nil
    }
    
    private func configureFighterLights(on node: SCNNode) {
        node.scale = sceneModel.fighterScale
        
        // Remove existing light nodes to prevent accumulation
        node.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.position = SCNVector3(x: 0.0, y: -5.0, z: 0.0)
        cabinLightNode.light?.type = .omni
        cabinLightNode.light?.castsShadow = false
        cabinLightNode.light?.attenuationStartDistance = 1.0
        cabinLightNode.light?.attenuationEndDistance = 5.0
        cabinLightNode.light?.color = sceneModel.cabinLightColor
        cabinLightNode.light?.intensity = sceneModel.omniLightIntensity
        node.addChildNode(cabinLightNode)
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        engineLightNode.light?.type = .omni
        engineLightNode.light?.castsShadow = false
        engineLightNode.light?.attenuationStartDistance = 1.0
        engineLightNode.light?.attenuationEndDistance = 5.0
        engineLightNode.light?.color = sceneModel.engineLightColor
        engineLightNode.light?.intensity = sceneModel.omniLightIntensity
        node.addChildNode(engineLightNode)
    }
    
    private func configureGenericLights(on node: SCNNode) {
        // Remove existing added lights to prevent accumulation
        node.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.white
        lightNode.light?.intensity = sceneModel.omniLightIntensity
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        node.addChildNode(lightNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
        uiView.scene?.background.contents = UIColor.black
        uiView.antialiasingMode = sceneModel.antialiasingMode
        
        // Re-apply our camera on every SwiftUI update cycle
        if let appCamera = scene.rootNode.childNode(withName: "appCamera", recursively: true) {
            uiView.pointOfView = appCamera
        }
        
        configureSceneNode(in: uiView)
    }
}
