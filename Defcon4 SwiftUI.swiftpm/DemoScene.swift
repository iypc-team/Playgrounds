//  
//  

import SceneKit

func makeDemoScene() -> SCNScene {
    let scene = SCNScene()
    
    // Example geometry – a spinning box
    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    let boxNode = SCNNode(geometry: box)
    boxNode.name = "box"
    scene.rootNode.addChildNode(boxNode)
    
    // Simple camera
    let camera = SCNCamera()
    let camNode = SCNNode()
    camNode.camera = camera
    camNode.position = SCNVector3(x: 0, y: 0, z: 5)
    scene.rootNode.addChildNode(camNode)
    
    return scene
}
