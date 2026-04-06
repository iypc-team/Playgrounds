// SceneViewModel.swift
// 

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
        // Remove existing camera and light nodes to prevent accumulation
        scene.rootNode.childNodes.filter { $0.camera != nil }.forEach { $0.removeFromParentNode() }
        scene.rootNode.childNodes.filter { $0.light != nil && $0.light!.type == .ambient }.forEach { $0.removeFromParentNode() }
        
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
        guard SCNScene(named: name) != nil else {
            print("Scene '\(name)' could not be found or loaded. Falling back to empty scene.")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
            sceneModel.sceneName = name  // Still set for reporting, but note it's invalid
            return
        }
        
        if let loadedScene = SCNScene(named: name) {
            self.scene = loadedScene
            sceneModel.sceneName = name
            sceneModel.setScene(loadedScene)
        } else {
            // This shouldn't happen due to the guard, but kept for safety
            print("Failed to load scene: \(name)")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
        }
        setupScene()  // Reconfigure camera and lights for new scene
    }
}
