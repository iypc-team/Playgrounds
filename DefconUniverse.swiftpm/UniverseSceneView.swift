// UniverseSceneView.swift
// 

import SwiftUI
import SceneKit

struct UniverseSceneView: UIViewRepresentable {
    
    @Binding var isRotating: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene                   = buildScene()
        scnView.allowsCameraControl     = false
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor         = .black
        scnView.antialiasingMode        = .multisampling4X
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let cameraNode = uiView.scene?.rootNode.childNode(
            withName: "cameraNode", recursively: false
        ) else { return }
        
        cameraNode.isPaused = !isRotating
    }
    
    // MARK: - Scene Construction
    
    private func buildScene() -> SCNScene {
        let scene = SCNScene()
        
        // ── Universe background sphere ──────────────────────────────
        let universeNode = Universe.createNode()
        scene.rootNode.addChildNode(universeNode)
        
        // ── Camera ─────────────────────────────────────────────────
        let camera = SCNCamera()
        camera.zNear        = 1
        camera.zFar         = Double(Universe.radius)
        camera.fieldOfView  = 100
        
        let cameraNode = SCNNode()
        cameraNode.name     = "cameraNode"
        cameraNode.camera   = camera
        cameraNode.position = SCNVector3Zero
        
        // ── Continuous z-axis rotation (~15 s per full revolution) ──
        let rotateAction = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: 0, z: .pi * 2, duration: 15.0)
        )
        cameraNode.runAction(rotateAction, forKey: "zRotation")
        
        scene.rootNode.addChildNode(cameraNode)
        return scene
    }
}
