//// 
//// 
//
//import SceneKit
//import UIKit   // or AppKit on macOS
//
//// 1️⃣ Create the geometry – a sphere with a given radius
//let sphereGeometry = SCNSphere(radius: 0.5)   // radius in scene units
//
//// Optional: customize the appearance
//sphereGeometry.firstMaterial?.diffuse.contents = UIColor.systemTeal   // color
//sphereGeometry.firstMaterial?.specular.contents = UIColor.white      // highlights
//sphereGeometry.firstMaterial?.shininess = 0.8                       // surface gloss
//
//// 2️⃣ Wrap the geometry in a node
//let sphereNode = SCNNode(geometry: sphereGeometry)
//
//// Position the node in the scene (optional)
//// Here we place it 0 meters up on the Y‑axis and 2 meters back on Z‑axis
//sphereNode.position = SCNVector3(x: 0, y: 0.5, z: -2)
//
//// 3️⃣ Add the node to your scene’s root node (or any other parent node)
//let scene = SCNScene()
//scene.rootNode.addChildNode(sphereNode)
//
//// If you’re using an SCNView (e.g., in a view controller):
//let scnView = SCNView(frame: view.bounds)
//scnView.scene = scene
//scnView.allowsCameraControl = true   // lets you orbit/zoom with gestures
//scnView.backgroundColor = .black
//view.addSubview(scnView)
