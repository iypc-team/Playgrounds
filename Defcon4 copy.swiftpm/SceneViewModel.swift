//  SceneViewModel.swift
//  

import SwiftUI
import SceneKit
import Foundation
import os  // need this import for logging

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    // List of all scene files in Resources/ to cycle through
    private let sceneFiles = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighter.usdg",
        "fighterPBR.scn",
        "newFighter.scn",
        "new_enemy.scn",
        "smooth_ship.scn"
    ]
    private var currentSceneIndex = 0  // Index to track current scene
    
    // Initialize a logger for this view model
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Defcon4", category: "SceneViewModel")
    
    init() {
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
        loadScene(for: sceneModel.sceneName)  // Load initial scene
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
    
    // Method to load a scene by name
    private func loadScene(for name: String) {
        if let loadedScene = SCNScene(named: name) {
            self.scene = loadedScene  // Update to loaded scene
            sceneModel.sceneName = name  // Update model
            logger.info("Loaded scene: \(loadedScene.description, privacy: .public)")
            logger.debug("Scene physics behaviors: \(self.scene.physicsWorld.allBehaviors, privacy: .public)")
        } else {
            logger.warning("Failed to load scene named '\(name)'")
        }
        setupScene()  // Reconfigure camera and lights for new scene
    }
    
    // Method to cycle to the next scene in the list
    func nextScene() {
        currentSceneIndex = (currentSceneIndex + 1) % sceneFiles.count
        let nextFile = sceneFiles[currentSceneIndex]
        loadScene(for: nextFile)
    }
    
    private func positionRadarNode(_ radarNode: SCNNode) {
        guard let geometry = radarNode.geometry else { 
            logger.error("Radar node has no geometry.")
            return 
        }
        
        let boundingBox = geometry.boundingBox
        var length = boundingBox.max.y - boundingBox.min.y  // Operate on y-axis only
        length += length / 2.5
        logger.info("Calculated radar length: \(length, privacy: .public)")
        sceneModel.radarPosition = SCNVector3(x: 0.0, y: length / 2.0, z: 0)
    }
}
