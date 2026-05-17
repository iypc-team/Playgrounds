//  SceneKitView.swift

import SwiftUI
import SceneKit

// Matches Color(UIColor.darkGray) used in ContentView
private let sceneBackground = UIColor.darkGray

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.scene?.background.contents = sceneBackground
        scnView.backgroundColor = sceneBackground
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = sceneModel.antialiasingMode
        applyCamera(to: scnView)
        configureSceneLights(in: scnView)
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
        uiView.scene?.background.contents = sceneBackground
        uiView.backgroundColor = sceneBackground
        uiView.antialiasingMode = sceneModel.antialiasingMode
        applyCamera(to: uiView)
        configureSceneLights(in: uiView)
    }
    
    // MARK: - Camera
    
    /// Forces the app-created camera as pointOfView so embedded .scn cameras
    /// don't override the auto-framed viewpoint set by SceneViewModel.
    private func applyCamera(to scnView: SCNView) {
        if let cam = scene.rootNode.childNode(withName: "appCamera", recursively: true) {
            scnView.pointOfView = cam
        }
    }
    
    // MARK: - Per-Scene Lighting
    
    private func configureSceneLights(in scnView: SCNView) {
        if let fighterNode = scene.rootNode.childNode(withName: "fighter", recursively: true) {
            configureFighterLights(on: fighterNode)
        } else if let geometryNode = firstNodeWithGeometry(in: scene.rootNode) {
            configureGenericLight(on: geometryNode)
        }
    }
    
    private func configureFighterLights(on node: SCNNode) {
        node.scale = sceneModel.fighterScale
        node.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        
        node.addChildNode(makeOmniLight(
            position: SCNVector3(0, -5, 0),
            color: sceneModel.cabinLightColor,
            intensity: sceneModel.omniLightIntensity
        ))
        node.addChildNode(makeOmniLight(
            position: SCNVector3(0, 0, 0),
            color: sceneModel.engineLightColor,
            intensity: sceneModel.omniLightIntensity
        ))
    }
    
    private func configureGenericLight(on node: SCNNode) {
        node.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        node.addChildNode(makeOmniLight(
            position: SCNVector3(0, 10, 10),
            color: .white,
            intensity: sceneModel.omniLightIntensity
        ))
    }
    
    // MARK: - Helpers
    
    private func makeOmniLight(position: SCNVector3,
                               color: UIColor,
                               intensity: CGFloat) -> SCNNode {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = .omni
        node.light!.color = color
        node.light!.intensity = intensity
        node.light!.castsShadow = false
        node.light!.attenuationStartDistance = 1.0
        node.light!.attenuationEndDistance = 5.0
        node.position = position
        return node
    }
    
    private func firstNodeWithGeometry(in node: SCNNode) -> SCNNode? {
        if node.geometry != nil { return node }
        for child in node.childNodes {
            if let found = firstNodeWithGeometry(in: child) { return found }
        }
        return nil
    }
}
