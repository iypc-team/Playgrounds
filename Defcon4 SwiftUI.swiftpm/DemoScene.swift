//  
//  SceneKit SCNSphere SCNMaterial UIImage

import SceneKit
import UIKit

func createUniverse(thisScene: SCNScene) -> SCNScene {
    // 1. Create a SceneKit sphere
    let sphere = SCNSphere(radius: 10.0)
    // 2. Create a material and load an image (UIImage)
    let material = SCNMaterial()
    if let image = UIImage(named: "JWST1") {
        material.diffuse.contents = image
        material.isDoubleSided = true
        material.diffuse.wrapS = .repeat 
        material.diffuse.wrapT = .clamp 
    }
    // 3. Assign the material to the sphere
    sphere.materials = [material]
    // 4. Create a node to hold the sphere
    let sphereNode = SCNNode(geometry: sphere)
    // 5. Optionally, add the sphereNode to a scene
//    let scene = SCNScene()
    thisScene.rootNode.addChildNode(sphereNode)
    
    return thisScene
}

func makeDemoScene() -> SCNScene {
    let scene = SCNScene()
    
    // Example geometry – a spinning box
    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    let boxNode = SCNNode(geometry: box)
    boxNode.name = "box"
    scene.rootNode.addChildNode(boxNode)
    
    // 1. Create a SceneKit sphere
    let sphere = SCNSphere(radius: 3.0)
    // 2. Create a material and load an image (UIImage)
    let material = SCNMaterial()
    if let image = UIImage(named: "JWST1") {
        material.diffuse.contents = image
        material.isDoubleSided = true
        material.diffuse.wrapS = .repeat 
        material.diffuse.wrapT = .clamp 
    }
    
    sphere.materials = [material] // 3. Assign the material to the sphere
    // 4. Create a node to hold the sphere
    let sphereNode = SCNNode(geometry: sphere)
    // 5. Optionally, add the sphereNode to a scene
    scene.rootNode.addChildNode(sphereNode)
    
    
    let universeSphere = SCNSphere(radius: 2)
    universeSphere.firstMaterial?.diffuse.contents = UIColor.blue
    universeSphere.isGeodesic = true
    let universeNode = SCNNode(geometry: universeSphere)
    universeNode.name = "universe"
    scene.rootNode.addChildNode(universeNode)
    
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
    camNode.position = SCNVector3(x: 0, y: 0, z: 10)
    scene.rootNode.addChildNode(camNode)
    
    print(scene.rootNode.childNodes)
    return scene
}
   
