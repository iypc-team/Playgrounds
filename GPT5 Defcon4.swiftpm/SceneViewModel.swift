// 
// 

import SceneKit
import Combine

class SceneViewModel: ObservableObject {
    @Published var scene: SCNScene
    @Published var selectedNode: SCNNode?
    
    init() {
        scene = SCNScene()
        setupScene()
    }
    
    func setupScene() {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 1.0))
        sphereNode.position = SCNVector3(0, 0, 0)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func updateNodeColor(node: SCNNode, color: UIColor) {
        node.geometry?.firstMaterial?.diffuse.contents = color
    }
}

