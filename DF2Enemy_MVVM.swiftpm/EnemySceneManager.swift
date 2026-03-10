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
        
        // Configure ship
        configureShip(in: enemyScene)
        
        return enemyScene
    }
    
    private func configureShip(in enemyScene: SCNScene) {
        guard let enemyShipNode = enemyScene.rootNode.childNode(withName: "enemy", recursively: true) else { return }
        self.enemyShipNode = enemyShipNode  // Fixed: Assign to the private property
        
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
        if let materials = enemyShipNode?.geometry?.materials {
            print("Materials in enemyShipNode:")
            for (index, material) in materials.enumerated() {
                print("Material \(index): \(material.name ?? "Unnamed")")
            }
        } else {
            print("No materials found in enemyShipNode.")
        }
    }
}
