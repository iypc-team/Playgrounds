// DefconUniverse  05/20/2026-1
// UniverseSceneView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/DefconUniverse.swiftpm

import SwiftUI
import SceneKit

struct UniverseSceneView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .black
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling2X
        
        let scene = SCNScene()
        
        // Add universe background sphere
        let universeNode = Universe.createNode()
        scene.rootNode.addChildNode(universeNode)
        
        // Camera positioned at center looking outward
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 2048 * 2
        cameraNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        scnView.pointOfView = cameraNode
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}
