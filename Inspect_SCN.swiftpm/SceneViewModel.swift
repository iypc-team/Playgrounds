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
        self.scene = SCNScene()
        self.sceneModel = SceneModel()
    }
    
    func setupScene() {
        // Remove existing camera and light nodes to prevent accumulation
        scene.rootNode.childNodes.filter { $0.camera != nil }.forEach { $0.removeFromParentNode() }
        scene.rootNode.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup ambient light — increased intensity for better base illumination
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity * 2
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Setup omni directional lights so ALL scenes are visible
        let omniLightNode1 = SCNNode()
        omniLightNode1.light = SCNLight()
        omniLightNode1.light!.type = .omni
        omniLightNode1.light!.color = UIColor.darkGray
        omniLightNode1.light!.intensity = sceneModel.omniLightIntensity * 1.5
        omniLightNode1.position = SCNVector3(x: 0, y: 10, z: 20)
        scene.rootNode.addChildNode(omniLightNode1)
        
        // Add a second omni light for opposite side coverage
        let omniLightNode2 = SCNNode()
        omniLightNode2.light = SCNLight()
        omniLightNode2.light!.type = .omni
        omniLightNode2.light!.color = UIColor.darkGray
        omniLightNode2.light!.intensity = sceneModel.omniLightIntensity * 1.5
        omniLightNode2.position = SCNVector3(x: 0, y: 10, z: -20)
        scene.rootNode.addChildNode(omniLightNode2)
        
        // Add directional light for global depth and shadows
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light!.type = .directional
        directionalLightNode.light!.color = UIColor.white
        directionalLightNode.light!.intensity = sceneModel.omniLightIntensity * 0.8
        directionalLightNode.light!.castsShadow = true
        directionalLightNode.eulerAngles = SCNVector3(x: -Float.pi / 4, y: 0, z: 0)
        scene.rootNode.addChildNode(directionalLightNode)
    }
    
    // MARK: - Load a scene by file name
    // Uses multiple strategies to locate the .scn file in the bundle:
    //   1. Standard Bundle.main.url(forResource:withExtension:)
    //   2. Recursive FileManager search (handles spaces in filenames and
    //      SPM-relocated resources)
    @discardableResult
    func loadScene(for name: String) -> Bool {
        let fileNameWithoutExtension = (name as NSString).deletingPathExtension
        let fileExtension = (name as NSString).pathExtension
        
        // Strategy 1: Standard bundle lookup
        var url = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension)
        
        // Strategy 2: If standard lookup fails (common with spaces in filenames),
        // recursively search the bundle for a file whose lastPathComponent matches.
        if url == nil {
            print("Standard bundle lookup failed for '\(name)', falling back to recursive search.")
            url = findFileInBundle(named: name)
        }
        
        guard let resolvedURL = url else {
            print("Scene '\(name)' could not be found in the bundle by any strategy.")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
            sceneModel.sceneName = name
            setupScene()
            return false
        }
        
        do {
            let loadedScene = try SCNScene(url: resolvedURL, options: nil)
            self.scene = loadedScene
            sceneModel.sceneName = name
            sceneModel.setScene(loadedScene)
        } catch {
            print("Failed to load scene '\(name)': \(error.localizedDescription)")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
            setupScene()
            return false
        }
        
        setupScene()
        return true
    }
    
    // MARK: - Recursive bundle file search
    // Walks the entire bundle directory tree to find a file by its exact name.
    // This handles filenames with spaces, percent-encoded paths, and files
    // nested in subdirectories by SPM's .process() directive.
    private func findFileInBundle(named fileName: String) -> URL? {
        guard let bundleURL = Bundle.main.resourceURL else { return nil }
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: bundleURL,
                                                      includingPropertiesForKeys: nil,
                                                      options: [.skipsHiddenFiles]) else {
            return nil
        }
        while let fileURL = enumerator.nextObject() as? URL {
            if fileURL.lastPathComponent == fileName {
                return fileURL
            }
        }
        return nil
    }
}
