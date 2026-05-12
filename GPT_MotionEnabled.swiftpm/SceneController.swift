// SceneController.swift
// 

import SceneKit

final class SceneController {
    
    let scene = SCNScene()
    
    private let configuration = SceneConfiguration()
    
    private(set) var shipNode: SCNNode?
    private(set) var shieldsNode: SCNNode?
    
    // Preloaded ships cache
    private var preloadedShips: [ShipType: SCNNode] = [:]
    
    init() {
        setupCamera()
        setupLighting()
        // Preload all ships in background
        Task.detached { await self.preloadAllShips() }
    }
    
    // MARK: - Preloading
    
    private func preloadAllShips() async {
        for type in ShipType.allCases {
            guard let loadedScene = SCNScene(named: type.sceneFileName) else {
                continue
            }
            
            let rootNode = await loadedScene.rootNode.childNode(
                withName: type.rootNodeName, 
                recursively: true
            ) ?? loadedScene.rootNode
            
            let clone = await rootNode.clone()
            
            await MainActor.run {
                self.preloadedShips[type] = clone
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 15)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 400
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)
        
        // Directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1200
        directionalLight.position = SCNVector3(10, 15, 20)
        directionalLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(directionalLight)
    }
    
    // MARK: - Ship Management
    
    func loadShip(_ type: ShipType) {
        // Remove current ship
        shipNode?.removeFromParentNode()
        
        // Get preloaded ship or fallback
        let ship = preloadedShips[type]?.clone() ?? fallbackLoad(type)
        
        shipNode = ship
        ship.orientation = SCNVector4(0, 0, 0, 1) // Reset to neutral
        
        attachSceneContent(to: ship)
        scene.rootNode.addChildNode(ship)
    }
    
    private func fallbackLoad(_ type: ShipType) -> SCNNode {
        guard let loadedScene = SCNScene(named: type.sceneFileName) else {
            return SCNNode()
        }
        
        let root = loadedScene.rootNode.childNode(
            withName: type.rootNodeName, 
            recursively: true
        ) ?? loadedScene.rootNode
        
        return root
    }
    
    private func attachSceneContent(to node: SCNNode) {
        // Add shields
        let shields = ShieldFactory.makeShieldNode()
        shieldsNode = shields
        node.addChildNode(shields)
        
        // Add engine lights
        for lightConfig in configuration.engineLights {
            let lightNode = SceneLighting.makeLightNode(from: lightConfig)
            node.addChildNode(lightNode)
        }
    }
    
    // MARK: - Helper
    
    var currentShipNode: SCNNode? {
        shipNode
    }
}
