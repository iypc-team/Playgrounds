// 
// 

import SceneKit
import UIKit

class SceneModel  {
    // 3D Scene
    var scene: SCNScene?
    var cameraNode: SCNNode?
    var lightNodes: [SCNNode] = []
    
    init(sceneName: String, cameraPosition: SCNVector3) {
        // Load the scene
        self.scene = SCNScene(named: sceneName)
        
        // Configure the camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = cameraPosition
        self.cameraNode = cameraNode
        
        // Add the camera node to the scene
        self.scene?.rootNode.addChildNode(cameraNode)
        
        // Configure lights
        configureDefaultLights()
    }
    
    private func configureDefaultLights() {
        // Primary light source
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .ambient
        lightNode.light!.color = UIColor.white
        lightNode.light!.intensity = 100
        lightNodes.append(lightNode)
        
        lightNode.position = SCNVector3(x: 0, y: 100, z: 100)
        scene?.rootNode.addChildNode(lightNode)
        
        // Additional lights can be added here
    }
}

