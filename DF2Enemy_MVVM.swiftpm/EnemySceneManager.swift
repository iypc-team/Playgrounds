//  EnemySceneManager.swift
//  DF2Enemy_MVVM.swiftpm
//  
//  

import SceneKit
import UIKit

class EnemySceneManager {
    private var enemyShipNode: SCNNode?
    private var rotationAction: SCNAction?
    
    func setupEnemyScene() -> SCNScene {
        guard let  enemyScene = SCNScene(named: "smooth_ship.scn") else {
            fatalError("Error: Could not load the SceneKit asset 'smooth_ship.scn'. Verify the file exists in the project's resources.")
//            print("enemyScene: \(enemyScene.rootNode.childNodes)")
        }
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        enemyScene.rootNode.addChildNode(cameraNode)
        
        // Setup ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .omni
        ambientLightNode.light!.color = UIColor.darkGray
        enemyScene.rootNode.addChildNode(ambientLightNode)
        
        // Setup omni lights
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: 100), in: enemyScene)
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: -100), in: enemyScene)
        
        // Configure ship
        configureShip(in: enemyScene)
        
        return enemyScene
    }
    
    private func setupOmniLight(at position: SCNVector3, in enemyScene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = position
        enemyScene.rootNode.addChildNode(lightNode)
    }
    
    private func configureShip(in enemyScene: SCNScene) {
        guard let enemyShipNode = enemyScene.rootNode.childNode(withName: "enemy", recursively: true) else { return }
        self.enemyShipNode = enemyShipNode  // Fixed: Assign to the private property
        enemyShipNode.geometry?.firstMaterial?.isDoubleSided = true
        enemyShipNode.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.darkGray
        enemyShipNode.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
        enemyShipNode.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
        print()
        getOrientation()
        getEnemyShipMaterials()
    }
    
    func startAnimation() {
        guard let enemyShipNode = self.enemyShipNode else { return }
        rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1))
        enemyShipNode.runAction(rotationAction!)
    }
    
    func stopAnimation() {
        enemyShipNode?.removeAllActions()
        rotationAction = nil
    }
    
    // Additional methods for enemy-specific logic can be added here
    // e.g., updating enemy ship properties, handling animations, etc.
    
    func getOrientation() { 
        let enemyOrientation = enemyShipNode?.orientation
        print("orientation: \(String(describing: enemyOrientation))")
    }
    
    func getEnemyShipMaterials() { 
        let materialCount = enemyShipNode?.geometry?.materials.count
        print("materialCount: \(String(describing: materialCount))")
    }
}
