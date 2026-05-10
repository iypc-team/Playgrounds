//
// SceneController.swift
//

import SceneKit

final class SceneController {
    
    let scene = SCNScene()
    
    private let configuration = SceneConfiguration()
    
    private(set) var shipNode: SCNNode?
    
    private(set) var shieldsNode: SCNNode?
    
    init() {
        setupCamera()
        setupLighting()
    }
    
    private func setupCamera() {
        
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = configuration.camera.position
        
        cameraNode.camera?.automaticallyAdjustsZRange =
        configuration.camera.automaticallyAdjustsZRange
        
        cameraNode.look(at: configuration.camera.lookAt)
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        
        for light in configuration.ambientLights {
            
            scene.rootNode.addChildNode(
                SceneLighting.makeLightNode(from: light)
            )
        }
    }
    
    func loadShip(_ type: ShipType) {
        
        shipNode?.removeFromParentNode()
        
        guard let loadedScene = SCNScene(named: type.sceneFileName) else {
            print("scene.error")
            
            return
        }
        
        let rootNodeName = type.rootNodeName
        
        let loadedShip =
        loadedScene.rootNode.childNode(
            withName: rootNodeName,
            recursively: true
        )
        ?? loadedScene.rootNode
        
        shipNode = loadedShip
        
        shipNode?.orientation = SCNVector4(0, 0, 0, 1)
        
        attachSceneContent(to: loadedShip)
        
        scene.rootNode.addChildNode(loadedShip)
    }
    
    private func attachSceneContent(to node: SCNNode) {
        
        let shields = ShieldFactory.makeShieldNode()
        
        shieldsNode = shields
        
        node.addChildNode(shields)
        
        for light in configuration.engineLights {
            
            node.addChildNode(
                SceneLighting.makeLightNode(from: light)
            )
        }
    }
}

