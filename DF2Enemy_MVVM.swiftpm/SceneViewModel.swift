// ViewModel: Handles scene logic, setup, and state
// 

import SwiftUI
import SceneKit

class SceneViewModel: ObservableObject {
    @Published var enemyShip: EnemyShipModel = EnemyShipModel()
    private let scene = SCNScene(named: "smooth_ship.scn")!
    
    func setupScene() -> SCNScene {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Setup omni lights
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: 100))
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: -100))
        
        // Setup engine light
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.light!.type = .omni
        engineLightNode.light!.color = UIColor.red
        engineLightNode.light!.intensity = 7000 * 4
        engineLightNode.light!.castsShadow = true
        engineLightNode.position = enemyShip.position
        scene.rootNode.addChildNode(engineLightNode)
        
        // Configure ship
        configureShip()
        
        return scene
    }
    
    private func setupOmniLight(at position: SCNVector3) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = position
        scene.rootNode.addChildNode(lightNode)
    }
    
    private func configureShip() {
        guard let enemyShipNode = scene.rootNode.childNode(withName: "enemy", recursively: true) else { return }
        enemyShipNode.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.black
        enemyShipNode.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
        enemyShipNode.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
        
        // Add engine light to ship
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.light!.type = .omni
        engineLightNode.light!.color = UIColor.red
        engineLightNode.light!.intensity = 7000 * 4
        engineLightNode.light!.castsShadow = true
        enemyShipNode.addChildNode(engineLightNode)
        
        // Start animation
        let rotationDegrees = CGFloat(GLKMathDegreesToRadians(45.0))
        enemyShipNode.runAction(SCNAction.repeatForever(SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)))
    }
}

