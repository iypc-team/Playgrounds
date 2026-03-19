//  UniverseSceneManager.swift
//  DF2Enemy_MVVM.swiftpm
//  
//  

import SceneKit
import UIKit

class UniverseSceneManager {
    private var universeScene: SCNScene = SCNScene()
    
    init() {
        
        // Initialize with an empty scene; setup can be called separately
    }
    
    func setupUniverse() -> SCNScene {
        let universe = SCNSphere(radius: 2048.0 * 4)
        let universeNode = SCNNode(geometry: universe)
        universeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "JWST_2.png")
        universeNode.geometry?.firstMaterial?.isDoubleSided = true  // Make visible from inside
        
        // Add static physics body to universeNode for physics properties
        universeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: universe, options: nil))
        
        universeScene.rootNode.addChildNode(universeNode)
        
//        print("universeScene: \(universeScene.rootNode.childNodes)")
        
        // Setup omni lights
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: 100), in: universeScene)
        setupOmniLight(at: SCNVector3(x: 0, y: 0, z: -100), in: universeScene)
        
        return universeScene
    }
    
    // Additional methods for universe-specific logic can be added here
    // e.g., updating universe properties, adding dynamic elements, etc.
    
    private func setupOmniLight(at position: SCNVector3, in universeScene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = position
        universeScene.rootNode.addChildNode(lightNode)
    }
}
