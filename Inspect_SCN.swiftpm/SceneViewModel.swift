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
        
        // Setup ambient light (applies to ALL scenes, not just "fighter") - increased intensity for better base illumination
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity * 2  // Doubled for fuller coverage
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Setup a default omni directional light so ALL scenes are visible - increased intensity and added another for robustness
        let omniLightNode1 = SCNNode()
        omniLightNode1.light = SCNLight()
        omniLightNode1.light!.type = .omni
        omniLightNode1.light!.color = UIColor.darkGray
        omniLightNode1.light!.intensity = sceneModel.omniLightIntensity * 1.5  // Increased for stronger illumination
        omniLightNode1.position = SCNVector3(x: 0, y: 10, z: 20)
        scene.rootNode.addChildNode(omniLightNode1)
        
        // Add a second omni light for opposite side coverage
        let omniLightNode2 = SCNNode()
        omniLightNode2.light = SCNLight()
        omniLightNode2.light!.type = .omni
        omniLightNode2.light!.color = UIColor.darkGray
        omniLightNode2.light!.intensity = sceneModel.omniLightIntensity * 1.5
        omniLightNode2.position = SCNVector3(x: 0, y: 10, z: -20)  // Opposite side
        scene.rootNode.addChildNode(omniLightNode2)
        
        // Add directional light for global depth and shadows - best case addition
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light!.type = .directional
        directionalLightNode.light!.color = UIColor.white
        directionalLightNode.light!.intensity = sceneModel.omniLightIntensity * 0.8  // Slightly less to avoid overpowering
        directionalLightNode.light!.castsShadow = true  // Enable shadows for realism
        directionalLightNode.eulerAngles = SCNVector3(x: -Float.pi / 4, y: 0, z: 0)  // Angled like sunlight
        scene.rootNode.addChildNode(directionalLightNode)
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
