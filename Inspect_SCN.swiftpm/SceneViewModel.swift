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
        scene.rootNode.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        
        // Setup camera — tagged so SceneKitView can force it as pointOfView
        let cameraNode = SCNNode()
        cameraNode.name = "appCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
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
        
        // Auto-frame the camera so ANY model is visible regardless of its
        // bounding box size or world-space position.
        frameCameraToContent()
    }
    
    // MARK: - Auto-frame the camera to fit all scene content
    /// Computes the bounding box of the entire root node, derives a bounding-
    /// sphere radius, and pulls the camera back far enough to see everything.
    /// Also repositions the omni lights to bracket the content.
    private func frameCameraToContent() {
        let (minVec, maxVec) = scene.rootNode.boundingBox
        
        let size = SCNVector3(
            maxVec.x - minVec.x,
            maxVec.y - minVec.y,
            maxVec.z - minVec.z
        )
        let center = SCNVector3(
            (minVec.x + maxVec.x) / 2,
            (minVec.y + maxVec.y) / 2,
            (minVec.z + maxVec.z) / 2
        )
        
        // Approximate bounding-sphere radius
        let radius = sqrt(size.x * size.x + size.y * size.y + size.z * size.z) / 2
        
        // If the scene is essentially empty, keep the default camera position
        guard radius > 0.001 else {
            print("frameCameraToContent: scene is empty, keeping default camera.")
            return
        }
        
        // Pull the camera back 2.5× the bounding-sphere radius
        let distance = Float(radius) * 2.5
        
        if let cameraNode = scene.rootNode.childNode(withName: "appCamera", recursively: false) {
            cameraNode.position = SCNVector3(center.x, center.y, center.z + distance)
            cameraNode.look(at: center)
            print("Camera auto-framed: center=(\(center.x), \(center.y), \(center.z)), radius=\(radius), distance=\(distance)")
        }
        
        // Reposition the two omni lights to bracket the content
        let lightNodes = scene.rootNode.childNodes.filter { $0.light?.type == .omni }
        if lightNodes.count >= 2 {
            lightNodes[0].position = SCNVector3(center.x, center.y + Float(radius), center.z + distance)
            lightNodes[1].position = SCNVector3(center.x, center.y + Float(radius), center.z - distance)
        }
    }
    
    // MARK: - Load a scene by file name
    @discardableResult
    func loadScene(for name: String) -> Bool {
        let fileNameWithoutExtension = (name as NSString).deletingPathExtension
        let fileExtension = (name as NSString).pathExtension
        
        // Strategy 0: Look inside "Resources" subdirectory first
        var url = Bundle.main.url(forResource: fileNameWithoutExtension,
                                  withExtension: fileExtension,
                                  subdirectory: "Resources")
        
        // Strategy 1: Standard bundle lookup (URL-based, top-level)
        if url == nil {
            print("Strategy 0 (subdirectory Resources) failed for '\(name)', trying top-level lookup.")
            url = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension)
        }
        
        // Strategy 2: String-based bundle lookup — handles spaces better on some platforms
        if url == nil {
            print("Strategy 1 (url forResource) failed for '\(name)', trying path-based lookup.")
            if let path = Bundle.main.path(forResource: fileNameWithoutExtension, ofType: fileExtension) {
                url = URL(fileURLWithPath: path)
            }
        }
        
        // Strategy 3: Recursive FileManager search by lastPathComponent match
        if url == nil {
            print("Strategy 2 (path forResource) failed for '\(name)', falling back to recursive search.")
            url = findFileInBundle(named: name)
        }
        
        // Strategy 4: Direct path construction from resourcePath
        if url == nil {
            print("Strategy 3 (recursive search) failed for '\(name)', trying direct path construction.")
            if let resourcePath = Bundle.main.resourcePath {
                let subDirPath = ((resourcePath as NSString).appendingPathComponent("Resources") as NSString).appendingPathComponent(name)
                if FileManager.default.fileExists(atPath: subDirPath) {
                    url = URL(fileURLWithPath: subDirPath)
                }
                if url == nil {
                    let directPath = (resourcePath as NSString).appendingPathComponent(name)
                    if FileManager.default.fileExists(atPath: directPath) {
                        url = URL(fileURLWithPath: directPath)
                    }
                }
            }
        }
        
        guard let resolvedURL = url else {
            print("Scene '\(name)' could not be found in the bundle by any strategy.")
            self.scene = SCNScene()
            sceneModel.setScene(self.scene)
            sceneModel.sceneName = name
            setupScene()
            return false
        }
        
        print("Successfully located '\(name)' at: \(resolvedURL.path)")
        
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
            if fileURL.path.removingPercentEncoding?.components(separatedBy: "/").last == fileName {
                return fileURL
            }
        }
        return nil
    }
}
