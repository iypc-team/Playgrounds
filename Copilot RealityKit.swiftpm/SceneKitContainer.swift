//// 
//// 
//
//import SceneKit
//
//struct SceneKitContainer: UIViewRepresentable {
//    var scene: SCNScene?
//    
//    func makeUIView(context: Context) -> SCNView {
//        let scnView = SCNView(frame: .zero)
//        scnView.allowsCameraControl = true
//        scnView.backgroundColor = .systemBackground
//        scnView.autoenablesDefaultLighting = true
//        scnView.scene = scene
//        // Optionally create a camera if your USDZ lacks one
//        if scnView.scene?.rootNode.childNode(withName: "camera", recursively: true) == nil {
//            let cameraNode = SCNNode()
//            cameraNode.camera = SCNCamera()
//            cameraNode.position = SCNVector3(x: 0, y: 0, z: 10) // adjust as needed
//            scnView.scene?.rootNode.addChildNode(cameraNode)
//        }
//        return scnView
//    }
//    
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // Swap scene when ViewModel updates
//        if uiView.scene !== scene {
//            uiView.scene = scene
//        }
//    }
//}

