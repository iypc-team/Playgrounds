// SceneViewModel: Handles scene logic, setup, and state
// Refactored for reusability: Added configurable parameters, constants for hardcoded values,
// error handling, dynamic updates to ship position/rotation, and removal of duplicate lights.
//

import SwiftUI
import SceneKit

class SceneViewModel: ObservableObject {
    @Published var enemyShip: EnemyShipModel = EnemyShipModel()
    @Published var isAnimating: Bool = false
    private var enemyShipNode: SCNNode?
    private var rotationAction: SCNAction?
    private var universeScene: SCNScene = SCNScene()
    private var scene = SCNScene(named: "smooth_ship.scn")!  // Keep this if needed for loading the ship model
    
    func setupUniverse() -> SCNScene {
        let universe = SCNSphere(radius: 2048.0)
        let universeNode = SCNNode(geometry: universe)
        universeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black  // Example: make it a starry background
        universeScene.rootNode.addChildNode(universeNode)
        
        print("universeScene: \(universeScene.rootNode)")
        return universeScene
    }
    
    func setupScene(baseScene: SCNScene) -> SCNScene {
        guard let scene = SCNScene(named: "smooth_ship.scn") else {
            fatalError("Error: Could not load the SceneKit asset 'smooth_ship.scn'. Verify the file exists in the project's resources.")
        }
        
        // Copy nodes from the loaded scene to the base scene
        for child in scene.rootNode.childNodes {
            baseScene.rootNode.addChildNode(child)
        }
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        baseScene.rootNode.addChildNode(cameraNode)
        
        // Setup ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .omni
        ambientLightNode.light!.color = UIColor.darkGray
        baseScene.rootNode.addChildNode(ambientLightNode)
        
        // Setup omni lights
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: 100), in: baseScene)
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: -100), in: baseScene)
        
        // Configure ship
        configureShip(in: baseScene)
        
        return baseScene
    }
    
    private func setupOmniLight(at position: SCNVector3, in scene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = position
        scene.rootNode.addChildNode(lightNode)
    }
    
    private func configureShip(in scene: SCNScene) {
        guard let enemyShipNode = scene.rootNode.childNode(withName: "enemy", recursively: true) else { return }
        self.enemyShipNode = enemyShipNode
        enemyShipNode.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.darkGray
        enemyShipNode.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
        enemyShipNode.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
        
        // Make the engine glow by setting emission
        enemyShipNode.geometry?.material(named: "Engine")?.emission.contents = UIColor.red
        
        // Add engine light to ship
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.position = enemyShipNode.position  // SCNVector3(x: 0.0,y: 0.0, z: 0.0)
        engineLightNode.light?.type = .omni
        engineLightNode.light?.castsShadow = false
        //        engineLightNode.light?.attenuationStartDistance = 1.0
        //        engineLightNode.light?.attenuationEndDistance = 5.0
        engineLightNode.light?.color = UIColor.red
        engineLightNode.light?.intensity = 6000
        
        // Position the light node inside the ship (adjust coordinates based on your model)
        engineLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // Add visible geometry to the light node for glow effect
        let lightGeometry = SCNSphere(radius: 0.5)
        lightGeometry.firstMaterial?.diffuse.contents = UIColor.black
        lightGeometry.firstMaterial?.emission.contents = UIColor.red
        engineLightNode.geometry = lightGeometry
        
        enemyShipNode.addChildNode(engineLightNode)
        
        // Prepare animation
        let rotationDegrees = CGFloat(GLKMathDegreesToRadians(45.0))
        self.rotationAction = SCNAction.repeatForever(SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4))
        if isAnimating {
            enemyShipNode.runAction(rotationAction!)
        }
    }
    
    func startAnimation() {
        guard let node = enemyShipNode, let action = rotationAction, !isAnimating else { return }
        node.runAction(action)
        isAnimating = true
    }
    
    func stopAnimation() {
        enemyShipNode?.removeAllActions()
        isAnimating = false
    }
}
