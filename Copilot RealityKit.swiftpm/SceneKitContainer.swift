// 
// 

import SwiftUI
import SceneKit

struct SceneKitContainer: UIViewRepresentable {
    var scene: SCNScene?
    
    func createUniverseNode() -> SCNNode {
        // 1️⃣ Create the geometry – a sphere with a given radius
        let universeGeometry = SCNSphere(radius: 0.25)   // radius in scene units
        
        // Optional: customize the appearance
        //universeGeometry.firstMaterial?.diffuse.contents = UIImage(named: "JPES1.jpg")
        universeGeometry.firstMaterial?.diffuse.contents = UIColor.systemTeal   // color
        universeGeometry.firstMaterial?.specular.contents = UIColor.clear      // highlights
        universeGeometry.firstMaterial?.shininess = 0.8                       // surface gloss
        
        // 2️⃣ Wrap the geometry in a node
        let universeNode = SCNNode(geometry: universeGeometry)
        
        // Position the node in the scene (optional)
        // Here we place it 0 meters up on the Y‑axis and 2 meters back on Z‑axis
        universeNode.position = SCNVector3(x: 0, y: 0.0, z: 0.0)
        return universeNode
    }
    
    func makeUIView(context: Context) -> SCNView {
        let thisUniverse = createUniverseNode()
        print("func makeUIView")
        print("context: \(context)\n")
        print("context.transaction: \(context.transaction)\n")
        print("context.coordinator: \(context.coordinator)")
        let scnView = SCNView(frame: .zero)
        scnView.allowsCameraControl = true
//        scnView.backgroundColor = .systemBackground
        scnView.backgroundColor = UIColor.black
        scnView.autoenablesDefaultLighting = true
        scnView.scene = scene
        // 
        scnView.scene?.rootNode.addChildNode(thisUniverse)
        
        // Optionally create a camera if your USDZ lacks one
        if scnView.scene?.rootNode.childNode(withName: "camera", recursively: true) == nil {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.automaticallyAdjustsZRange = true
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 10) // adjust as needed
            scnView.scene?.rootNode.addChildNode(cameraNode)
        }
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Swap scene when ViewModel updates
        if uiView.scene !== scene {
            uiView.scene = scene
        }
    }
}

