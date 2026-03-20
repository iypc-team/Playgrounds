//  UniverseSceneManager.swift
//  DF2Enemy_MVVM.swiftpm
//  

import SceneKit
import UIKit

class UniverseSceneManager {
    private let model = UniverseSceneModel()
    private var universeScene: SCNScene = SCNScene()
    
    init() {
        
        // Initialize with an empty scene; setup can be called separately
    }
    
    func setupUniverse() throws -> SCNScene {
        let universe = SCNSphere(radius: model.radius)
        let universeNode = SCNNode(geometry: universe)
        guard let image = UIImage(named: model.imageName) else {
            throw NSError(domain: "UniverseSceneManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not load image '\(model.imageName)'."])
        }
        universeNode.geometry?.firstMaterial?.diffuse.contents = image
        universeNode.geometry?.firstMaterial?.isDoubleSided = true  // Make visible from inside
        
        universeScene.rootNode.addChildNode(universeNode)
        
        // Setup omni lights
        for position in model.lightPositions {
            setupOmniLight(at: position, in: universeScene)
        }
        
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
