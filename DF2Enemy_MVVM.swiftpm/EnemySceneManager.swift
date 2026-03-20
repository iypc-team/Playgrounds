//  EnemySceneManager.swift
//  DF2Enemy_MVVM.swiftpm
//  

//  EnemySceneManager.swift
//  DF2Enemy_MVVM.swiftpm
//  

import SceneKit
import UIKit

class EnemySceneManager {
    private var enemyShipNode: SCNNode?
    private var rotationAction: SCNAction?
    private var shipModel = EnemyShipModel()  // Added to manage ship state
    
    func setupEnemyScene() throws -> SCNScene {
        guard let enemyScene = SCNScene(named: "smooth_ship.scn") else {
            throw NSError(domain: "EnemySceneManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load the SceneKit asset 'smooth_ship.scn'. Verify the file exists in the project's resources."])
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
        
        // Configure ship
        try configureShip(in: enemyScene)
        
        return enemyScene
    }
    
    private func configureShip(in enemyScene: SCNScene) throws {
        guard let enemyShipNode = enemyScene.rootNode.childNode(withName: "enemy", recursively: true) else {
            throw NSError(domain: "EnemySceneManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find 'enemy' node in the scene."])
        }
        self.enemyShipNode = enemyShipNode  // Fixed: Assign to the private property
        
        // Bind model's position, rotation, and orientation to the node
        enemyShipNode.position = shipModel.position
        enemyShipNode.eulerAngles = shipModel.rotation
        enemyShipNode.orientation = SCNQuaternion(shipModel.orientation.imag.x, shipModel.orientation.imag.y, shipModel.orientation.imag.z, shipModel.orientation.real)
        
        // Set all materials to be double-sided
        if let materials = enemyShipNode.geometry?.materials {
            for material in materials {
                material.isDoubleSided = true
            }
        }
        
        enemyShipNode.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.darkGray
        enemyShipNode.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
        enemyShipNode.geometry?.material(named: "Black_Exterior")?.diffuse.contents = UIColor.black
        enemyShipNode.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
    }
    
    func startAnimation() {
        guard let enemyShipNode = self.enemyShipNode else { return }
        rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 1))
        enemyShipNode.runAction(rotationAction!)
    }
    
    func stopAnimation() {
        enemyShipNode?.removeAllActions()
        rotationAction = nil
    }
    
    // Additional methods for enemy-specific logic can be added here
    // e.g., updating enemy ship properties, handling animations, etc.
}

//import SceneKit
//import UIKit
//
//class EnemySceneManager {
//    private var enemyShipNode: SCNNode?
//    private var rotationAction: SCNAction?
//    private var shipModel = EnemyShipModel()  // Added to manage ship state
//    
//    func setupEnemyScene() throws -> SCNScene {
//        guard let enemyScene = SCNScene(named: "smooth_ship.scn") else {
//            throw NSError(domain: "EnemySceneManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load the SceneKit asset 'smooth_ship.scn'. Verify the file exists in the project's resources."])
//        }
//        
//        // Setup camera
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.camera?.automaticallyAdjustsZRange = true
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
//        enemyScene.rootNode.addChildNode(cameraNode)
//        
//        // Setup ambient light
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .omni
//        ambientLightNode.light!.color = UIColor.darkGray
//        enemyScene.rootNode.addChildNode(ambientLightNode)
//        
//        // Configure ship
//        try configureShip(in: enemyScene)
//        
//        return enemyScene
//    }
//    
//    private func configureShip(in enemyScene: SCNScene) throws {
//        guard let enemyShipNode = enemyScene.rootNode.childNode(withName: "enemy", recursively: true) else {
//            throw NSError(domain: "EnemySceneManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find 'enemy' node in the scene."])
//        }
//        self.enemyShipNode = enemyShipNode  // Fixed: Assign to the private property
//        
//        // Bind model's position, rotation, and orientation to the node
//        enemyShipNode.position = shipModel.position
//        enemyShipNode.eulerAngles = shipModel.rotation
//        enemyShipNode.orientation = shipModel.orientation
//        // Cannot assign value of type 'simd_quatf' to type 'SCNQuaternion' (aka 'SCNVector4')
//        
//        // Set all materials to be double-sided
//        if let materials = enemyShipNode.geometry?.materials {
//            for material in materials {
//                material.isDoubleSided = true
//            }
//        }
//        
//        enemyShipNode.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.darkGray
//        enemyShipNode.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
//        enemyShipNode.geometry?.material(named: "Black_Exterior")?.diffuse.contents = UIColor.black
//        enemyShipNode.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
//    }
//    
//    func startAnimation() {
//        guard let enemyShipNode = self.enemyShipNode else { return }
//        rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1))
//        enemyShipNode.runAction(rotationAction!)
//    }
//    
//    func stopAnimation() {
//        enemyShipNode?.removeAllActions()
//        rotationAction = nil
//    }
//    
//    // Additional methods for enemy-specific logic can be added here
//    // e.g., updating enemy ship properties, handling animations, etc.
//}
