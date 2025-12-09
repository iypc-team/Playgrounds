//  Defcon4 12/08/2025-1
//  green

import SwiftUI
//import UIKit
import SceneKit
import Foundation

//struct Universe: UIViewRepresentable {
//    typealias UV = Universe
//    var universeScene: SCNScene? = SCNScene(named: "universe")
//    var universe: SCNSphere? = SCNNode(geometry: .sphere)
//    var universeNode: SCNNode? = SCNNode.init(geometry: universe)
//    
//    let globe = SCNSphere(radius: 1.0) 
//    let earthTexture = UIImage(named: "earth_texture")
//    let material: SCNMaterial = SCNMaterial()
//    material.diffuse.contents = earthTexture 
//    material.isDoubleSided = true 
//    material.diffuse.wrapS = .repeat 
//    material.diffuse.wrapT = .clamp 
//    globe.firstMaterial = material 
//}

struct SceneKitView : UIViewRepresentable {
    var universeScene: SCNScene? = SCNScene(named: "universe")
    
    var scene = SCNScene(named: "fighter.scn")!
    //    let shields = Static.ghostEffect()
    func makeUIView(context: Context) -> SCNView {
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 25)
        cameraNode.camera?.wantsHDR = true
        scene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.color = UIColor.clear
        lightNode.light!.type = .ambient
        lightNode.position = SCNVector3(x: 0, y: 100, z: 100)
        lightNode.light!.intensity = 500
        scene.rootNode.addChildNode(lightNode)
        
        let lightNode_2 = SCNNode()
        lightNode_2.light = SCNLight()
        lightNode_2.light!.type = .ambient
        lightNode_2.position = SCNVector3(x: 0, y: 0, z: -100)
        lightNode_2.light!.color = UIColor.white
        lightNode_2.light!.intensity = 100
        scene.rootNode.addChildNode(lightNode_2)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = 1000
        scene.rootNode.addChildNode(ambientLightNode)
        
        let shipLightNode = SCNNode()
        shipLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        shipLightNode.light = SCNLight()
        shipLightNode.light!.type = .omni
        shipLightNode.light!.intensity = 1000
        shipLightNode.light!.color =  UIColor.green
        scene.rootNode.addChildNode(shipLightNode)
        
        let shipLightNode2 = SCNNode()
        shipLightNode2.position = SCNVector3(x: 0, y: 0, z: 0)
        shipLightNode2.light = SCNLight()
        shipLightNode2.light!.type = .omni
        shipLightNode2.light!.intensity = 2500
        shipLightNode2.light!.color =  UIColor.green
        scene.rootNode.addChildNode(shipLightNode2)
        
        /////////////////////////  
        // Create a tube with a 0.5 m outer radius, 0.3 m inner radius, and 1 m height
        var tube = SCNTube(innerRadius: 0.0, outerRadius: 0.0625, height: 50.0)
        
        // Optional: increase segment counts for smoother geometry
        tube.radialSegmentCount = 4
        tube.heightSegmentCount = 4
        
        // Apply a material (e.g., a metallic look)
        var material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        material.metalness.contents = 0.8
        tube.materials = [material]
        
        // Wrap the geometry in a node
        let yAxis = SCNNode(geometry: tube)
        
        // Position the node in the scene
        yAxis.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(yAxis)        
        
        /////////////////////////  
        // Create a tube with a 0.5 m outer radius, 0.3 m inner radius, and 1 m height
        tube = SCNTube(innerRadius: 0.0, outerRadius: 0.0625, height: 50.0)
        
        // Optional: increase segment counts for smoother geometry
        tube.radialSegmentCount = 4
        tube.heightSegmentCount = 4
        
        // Apply a material (e.g., a metallic look)
        material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        material.metalness.contents = 0.8
        tube.materials = [material]
        
        // Wrap the geometry in a node
        let xAxis = SCNNode(geometry: tube)
        
        // Position the node in the scene
        xAxis.position = SCNVector3(x: 0, y: 0, z: 0)
        xAxis.eulerAngles.x = .pi / 2 
        
        // Add to your scene’s root node (or any parent node)
        scene.rootNode.addChildNode(xAxis)
        
        /////////////////////////  
        // Create a tube with a 0.5 m outer radius, 0.3 m inner radius, and 1 m height
        tube = SCNTube(innerRadius: 0.0, outerRadius: 0.0625, height: 50.0)
        
        // Optional: increase segment counts for smoother geometry
        tube.radialSegmentCount = 4
        tube.heightSegmentCount = 4
        
        // Apply a material (e.g., a metallic look)
        material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.metalness.contents = 0.8
        tube.materials = [material]
        
        // Wrap the geometry in a node
        let zAxis = SCNNode(geometry: tube)
        
        // Position the node in the scene
        zAxis.position = SCNVector3(x: 0, y: 0, z: 0)
        zAxis.eulerAngles.z = .pi / 2 
        
        // Add to your scene’s root node (or any parent node)
        scene.rootNode.addChildNode(zAxis)
        
        // retrieve the shipNode node
        let shipNode: SCNNode? = scene.rootNode.childNode(withName: "fighter.scn", recursively: true)
        shipNode?.addChildNode(shipLightNode)
        
        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.lightGray
    }
}

//struct SceneKitView_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneKitView()
//            .preferredColorScheme(.dark)
//    }
//}
