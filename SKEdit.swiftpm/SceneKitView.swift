// SceneKitView.swift
import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene?
    @Binding var cameraNode: SCNNode?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = UIColor.systemBackground
        scnView.showsStatistics = false
        scnView.debugOptions = [.showWireframe, .showSkeletons, .showBoundingBoxes]
        scnView.debugOptions = []
        scnView.preferredFramesPerSecond = 60
        
        if let scene = scene {
            scnView.scene = scene
            setupDefaultCamera(in: scnView, for: scene)
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
    }
    
    // MARK: - Camera Setup
    private func setupDefaultCamera(in scnView: SCNView, for scene: SCNScene) {
        // Check if scene already has a camera
        let existingCamera = scene.rootNode.childNodes.first { $0.camera != nil }
        
        if existingCamera == nil {
            let camera = SCNCamera()
            camera.zNear = 0.1
            camera.zFar = 1000
            camera.fieldOfView = 60
            
            let newCameraNode = SCNNode()
            newCameraNode.camera = camera
            newCameraNode.position = SCNVector3(x: 0, y: 8, z: 20)
            newCameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))   // Fixed safely
            
            scene.rootNode.addChildNode(newCameraNode)
            cameraNode = newCameraNode
        } else {
            cameraNode = existingCamera
        }
    }
}

// MARK: - Scene Loading Helper
extension SceneKitView {
    static func loadScene(from url: URL) throws -> SCNScene {
        return try SCNScene(url: url, options: [
            SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.play
        ])
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var cameraNode: SCNNode?
        @State private var testScene: SCNScene? = {
            let scene = SCNScene()
            let box = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0.5)
            let node = SCNNode(geometry: box)
            scene.rootNode.addChildNode(node)
            return scene
        }()
        
        var body: some View {
            SceneKitView(scene: testScene, cameraNode: $cameraNode)
                .frame(height: 500)
        }
    }
    
    return PreviewWrapper()
}
