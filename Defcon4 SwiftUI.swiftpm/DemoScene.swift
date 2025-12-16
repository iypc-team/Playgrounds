//  
//  SceneKit SCNSphere SCNMaterial UIImage MVVM paradigm

import SceneKit
import UIKit

func makeDemoScene() -> SCNScene {
    let scene = SCNScene()
    
    let sphere = SCNSphere(radius: 0.65)
    // 2. Create a material and load an image (UIImage)
    let material = SCNMaterial()
    if let image = UIImage(named: "JWST1") {
        material.diffuse.contents = image
        material.isDoubleSided = true
        material.diffuse.wrapS = .repeat 
        material.diffuse.wrapT = .clamp 
    }
    sphere.materials = [material]
    let sphereNode = SCNNode(geometry: sphere)
    scene.rootNode.addChildNode(sphereNode)
    
    // Example geometry – a spinning box
    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    let boxNode = SCNNode(geometry: box)
    boxNode.name = "box"
    scene.rootNode.addChildNode(boxNode)
    
    
    let xAxis = SCNTube(innerRadius: 0.0, outerRadius: 0.0625, height: 100.0)
    xAxis.firstMaterial?.diffuse.contents = UIColor.red
    let xAxisNode = SCNNode(geometry: xAxis)
    xAxisNode.position = SCNVector3(0, 0, 0)
    xAxisNode.eulerAngles = SCNVector3(0.0, 0.0, .pi / 2)
    scene.rootNode.addChildNode(xAxisNode)
    
    let yAxis = SCNTube(innerRadius: 0.0, outerRadius: 0.0625, height: 100)
    yAxis.firstMaterial?.diffuse.contents = UIColor.yellow
    let yAxisNode = SCNNode(geometry: yAxis)
    yAxisNode.position = SCNVector3(0, 0, 0)
    scene.rootNode.addChildNode(yAxisNode)
    
    let zAxis = SCNTube(innerRadius: 0.0, outerRadius: 0.0625, height: 100.0)
    zAxis.firstMaterial?.diffuse.contents = UIColor.blue
    let zAxisNode = SCNNode(geometry: zAxis)
    zAxisNode.position = SCNVector3(0, 0, 0)
    zAxisNode.eulerAngles = SCNVector3(.pi / 2, 0.0, 0.0)
    scene.rootNode.addChildNode(zAxisNode)
    
    // Simple camera
    let camera = SCNCamera()
    let camNode = SCNNode()
    camNode.camera = camera
    camNode.camera?.automaticallyAdjustsZRange = true
    camNode.position = SCNVector3(x: 0, y: 0, z: 20)
    scene.rootNode.addChildNode(camNode)
    
    
    print("\(scene.rootNode.childNodes)\n")
    return scene
}
   
