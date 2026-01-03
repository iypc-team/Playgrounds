// 
// 

import SceneKit
import UIKit

class SceneModel {
    var scene: SCNScene?
    var cameraNode: SCNNode?
    var lightNodes: [SCNNode] = []
    
    init(sceneName: String, cameraPosition: SCNVector3, lightIntensity: CGFloat = 100) {  // Added parameter
        self.scene = SCNScene(named: sceneName)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = cameraPosition
        self.cameraNode = cameraNode
        self.scene?.rootNode.addChildNode(cameraNode)
        configureDefaultLights(intensity: lightIntensity)
    }
    
    private func configureDefaultLights(intensity: CGFloat) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .ambient
        lightNode.light!.color = UIColor.white
        lightNode.light!.intensity = intensity  // Now configurable
        lightNodes.append(lightNode)
        lightNode.position = SCNVector3(x: 0, y: 100, z: 100)
        scene?.rootNode.addChildNode(lightNode)
    }
}
