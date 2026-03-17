//  SceneViewModel.swift
// 

import SwiftUI
import SceneKit
import Foundation

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    // Radar node property for access in computed variable
    var radarNode: SCNNode?
    
    // Computed variable for radar node position (y-axis), accessing radarNode.geometry height / 2
    var radarNodePosition: Float {
        guard let geometry = radarNode?.geometry as? SCNCone else { return 0 }
        return Float(geometry.height / 2)
    }
    
    // List of all scene files in Resources/ to cycle through
    private let sceneFiles = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighterPBR.scn",
        "newFighter.scn",
        "smooth_ship.scn"
    ]
    private var currentSceneIndex = 0  // Index to track current scene
    
    init() {
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
        loadScene(for: sceneModel.sceneName)  // Load initial scene
    }
    
    func setupScene() {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup radar node (made smaller and repositioned for visibility)
        let radarNode = SCNNode()
        radarNode.name = "radarNode"
        radarNode.position = SCNVector3(x: 0, y: radarNodePosition, z: 0)  // Initial position
        print("radarNode.position: \(radarNode.position)")
        radarNode.geometry = SCNCone(topRadius: 0.1, bottomRadius: 5.0, height: 10)  // Smaller scale
        
        // Create radar node material with white color and 0.1 opacity
        let radarNodeMaterial = SCNMaterial()
        radarNodeMaterial.name = "radarNodeMaterial"
        radarNodeMaterial.diffuse.contents = UIColor.white
        radarNodeMaterial.transparency = 0.1
        radarNode.geometry?.materials = [radarNodeMaterial]
        
//        scene.rootNode.addChildNode(radarNode)
        self.radarNode = radarNode  // Assign to property for computed access
        
        // Use radarNodePosition to set radarNode.position on the y-axis
        self.radarNode?.position.y = radarNodePosition
        
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
    
    // Method to cycle to the next scene in the list
    func nextScene() {
        currentSceneIndex = (currentSceneIndex + 1) % sceneFiles.count
        let nextFile = sceneFiles[currentSceneIndex]
        loadScene(for: nextFile)
    }
}
