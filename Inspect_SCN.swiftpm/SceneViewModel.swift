// SceneViewModel.swift

import SwiftUI
import SceneKit
import Foundation

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    init() {
        self.scene = SCNScene()
        self.sceneModel = SceneModel()
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
        
        // Setup ambient light (applies to ALL scenes, not just "fighter")
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Setup a default omni directional light so ALL scenes are visible
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = .omni
        omniLightNode.light!.color = UIColor.white
        omniLightNode.light!.intensity = sceneModel.omniLightIntensity
        omniLightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        scene.rootNode.addChildNode(omniLightNode)
    }
    
    // Method to load a scene by file name using URL-based loading
    func loadScene(for name: String) {
        let fileNameWithoutExtension = (name as NSString).deletingPathExtension
        let fileExtension = (name as NSString).pathExtension
        
        guard let url = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension) else {
            print("Scene '\(name)' could not be found in the bundle.")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
            sceneModel.sceneName = name
            return
        }
        
        do {
            let loadedScene = try SCNScene(url: url, options: nil)
            self.scene = loadedScene
            sceneModel.sceneName = name
            sceneModel.setScene(loadedScene)
        } catch {
            print("Failed to load scene '\(name)': \(error.localizedDescription)")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
        }
        
        setupScene()
    }
}
