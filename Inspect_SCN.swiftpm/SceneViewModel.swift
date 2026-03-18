// SceneViewModel.swift
// Updated: Removed hardcoded sceneFiles array, nextScene method, and initial loadScene call for consistency
// Scene:

import SwiftUI
import SceneKit
import Foundation

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    init() {
        
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
    }
    
    func setupScene() {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    // Method to load a scene by name
    func loadScene(for name: String) {
        if let loadedScene = SCNScene(named: name) {
            self.scene = loadedScene  // Update to loaded scene
            sceneModel.sceneName = name  // Update model
            sceneModel.setScene(loadedScene)  // Synchronize scene for inspection
        } else {
            print("Failed to load scene: \(name)")  // Added logging for debugging
            // Fallback to empty scene
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
        }
        setupScene()  // Reconfigure camera and lights for new scene
    }
}
