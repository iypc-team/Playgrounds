// SceneKitView.swift

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    
    @Binding var isRotating: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene       = buildScene()
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = .black
        scnView.antialiasingMode = .multisampling4X
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let cameraNode = uiView.scene?.rootNode.childNode(
            withName: "cameraNode", recursively: false
        ) else { return }
        
        if isRotating {
            cameraNode.isPaused = false
        } else {
            cameraNode.isPaused = true
        }
    }
    
    // MARK: Scene construction
    
    private func buildScene() -> SCNScene {
        let scene = SCNScene()
        
        // ── Universe background sphere ──────────────────────────────
        let universeNode = Universe.createNode()
        scene.rootNode.addChildNode(universeNode)
        
        // ── Camera ─────────────────────────────────────────────────
        let camera = SCNCamera()
        camera.zNear = 1
        camera.zFar  = Double(Universe.radius) * 2.0
        camera.fieldOfView = 100
        
        let cameraNode = SCNNode()
        cameraNode.name   = "cameraNode"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 0)
        
        // ── Continuous z-axis rotation  (~15 s per full revolution) ─
        let revolutionDuration: TimeInterval = 15.0
        let rotateAction = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi * 2, duration: revolutionDuration)
        )
        cameraNode.runAction(rotateAction, forKey: "zRotation")
        
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
}
