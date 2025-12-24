// 
// length:

import SwiftUI
import SceneKit
import Foundation
import os  // Add this import for logging

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    // Initialize a logger for this view model
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Defcon4", category: "SceneViewModel")
    
    init() {
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene  // Update to loaded scene if available
            logger.info("Loaded scene: \(loadedScene.description)")
            logger.debug("Scene physics behaviors: \(self.scene.physicsWorld.allBehaviors)")
        } else {
            logger.warning("Failed to load scene named '\(self.sceneModel.sceneName)'")
        }
        
        setupScene()  // Configure camera and lights
    }
    
    public func setupScene() {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup radar node
        let radarNode = SCNNode()
        radarNode.position = sceneModel.radarPosition  // Fix: Assign position from model
        radarNode.geometry = SCNCone(topRadius: 1.0, bottomRadius: 256, height: 1024)
        radarNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        
        scene.rootNode.addChildNode(radarNode)
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func positionRadarNode(_ radarNode: SCNNode) {
        guard let geometry = radarNode.geometry else { 
            logger.error("Radar node has no geometry.")
            return 
        }
        
        let boundingBox = geometry.boundingBox
        var length = boundingBox.max.y - boundingBox.min.y  // Operate on y-axis only
        length += length / 2.5
        logger.info("Calculated radar length: \(length)")
        sceneModel.radarPosition = SCNVector3(x: 0.0, y: length / 2.0, z: 0)
    }
}
