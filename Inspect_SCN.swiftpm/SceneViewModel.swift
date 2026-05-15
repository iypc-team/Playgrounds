//    SceneViewModel.swift
//  

import SwiftUI
import SceneKit

@MainActor
final class SceneViewModel: ObservableObject {
    
    @Published var scene: SCNScene
    @Published var sceneModel: SceneModel
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    init() {
        self.scene = SCNScene()
        self.sceneModel = SceneModel()           // Fixed: No argument
        setupEmptyScene()
        sceneModel.setScene(self.scene)          // Explicitly set the scene
    }
    
    // MARK: - Scene Loading
    
    func loadScene(for fileName: String) -> Bool {
        print("[loadScene] Attempting to load '\(fileName)'")
        
        guard let loadedScene = loadSceneNamed(fileName) else {
            print("[loadScene] ❌ Failed to load scene: \(fileName)")
            errorMessage = "Could not load scene: \(fileName)"
            showError = true
            return false
        }
        
        self.scene = loadedScene
        self.sceneModel = SceneModel()           // Fixed: No argument
        sceneModel.setScene(loadedScene)         // Use setter instead
        
        print("[loadSceneNamed] Loaded '\(fileName)' from bundle root")
        
        setupScene()
        frameCameraToContent()
        
        return true
    }
    
    private func loadSceneNamed(_ fileName: String) -> SCNScene? {
        if let scene = SCNScene(named: fileName) {
            return scene
        }
        if let scene = SCNScene(named: "Resources/\(fileName)") {
            return scene
        }
        
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".scn", with: ""),
                                     withExtension: "scn") {
            do {
                return try SCNScene(url: url, options: nil)
            } catch {
                print("[loadSceneNamed] URL load failed: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // MARK: - Scene Setup
    
    private func setupEmptyScene() {
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 400
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
        
        let omni = SCNLight()
        omni.type = .omni
        omni.intensity = 1200
        let omniNode = SCNNode()
        omniNode.light = omni
        omniNode.position = SCNVector3(10, 10, 15)
        scene.rootNode.addChildNode(omniNode)
    }
    
    private func setupScene() {
        // Clean previous app-controlled nodes
        scene.rootNode.childNode(withName: "appCamera", recursively: true)?.removeFromParentNode()
        scene.rootNode.childNode(withName: "appDirectionalLight", recursively: true)?.removeFromParentNode()
        
        // Force load any reference nodes
        scene.rootNode.enumerateChildNodes { node, _ in
            if let refNode = node as? SCNReferenceNode, !refNode.isLoaded {
                refNode.load()
                print("[setupScene] Forced load of SCNReferenceNode: \(node.name ?? "unnamed")")
            }
        }
        
        // App Camera
        let cameraNode = SCNNode()
        cameraNode.name = "appCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 1000
        scene.rootNode.addChildNode(cameraNode)
        
        // Strong directional light
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 1800
        directionalLight.castsShadow = true
        let lightNode = SCNNode()
        lightNode.name = "appDirectionalLight"
        lightNode.light = directionalLight
        lightNode.position = SCNVector3(15, 25, 20)
        scene.rootNode.addChildNode(lightNode)
        
        print("[setupScene] Scene configured with app camera + lights")
    }
    
    // MARK: - Camera Framing
    
    private func frameCameraToContent() {
        let root = scene.rootNode
        print("[frameCameraToContent] Root has \(root.childNodes.count) direct children")
        
        var allGeometryNodes: [SCNNode] = []
        
        func collectGeometry(_ node: SCNNode) {
            if node.geometry != nil {
                allGeometryNodes.append(node)
            }
            node.childNodes.forEach { collectGeometry($0) }
        }
        collectGeometry(root)
        
        print("[frameCameraToContent] Found \(allGeometryNodes.count) nodes with geometry")
        
        var minVec = SCNVector3(Float.infinity, Float.infinity, Float.infinity)
        var maxVec = SCNVector3(-Float.infinity, -Float.infinity, -Float.infinity)
        var hasValidContent = false
        
        for node in allGeometryNodes {
            let box = node.boundingBox
            guard box.min.x < box.max.x else { continue }
            
            let worldMin = node.convertPosition(box.min, to: nil)
            let worldMax = node.convertPosition(box.max, to: nil)
            
            minVec.x = min(minVec.x, worldMin.x)
            minVec.y = min(minVec.y, worldMin.y)
            minVec.z = min(minVec.z, worldMin.z)
            
            maxVec.x = max(maxVec.x, worldMax.x)
            maxVec.y = max(maxVec.y, worldMax.y)
            maxVec.z = max(maxVec.z, worldMax.z)
            
            hasValidContent = true
        }
        
        if !hasValidContent {
            print("[frameCameraToContent] ⚠️ No valid geometry found — keeping default camera.")
            return
        }
        
        // Center point
        let center = SCNVector3(
            (minVec.x + maxVec.x) * 0.5,
            (minVec.y + maxVec.y) * 0.5,
            (minVec.z + maxVec.z) * 0.5
        )
        
        let extentX = maxVec.x - minVec.x
        let extentY = maxVec.y - minVec.y
        let extentZ = maxVec.z - minVec.z
        let maxExtent = max(max(extentX, extentY), extentZ)
        let radius = maxExtent * 0.6 + 3.0
        
        guard let cameraNode = root.childNode(withName: "appCamera", recursively: true) else {
            print("[frameCameraToContent] ❌ App camera not found")
            return
        }
        
        // Position camera
        cameraNode.position = SCNVector3(
            center.x,
            center.y + radius * 0.7,
            center.z + radius * 1.4
        )
        
        // === SAFE LOOK-AT FOR iOS 16.6 ===
        cameraNode.look(at: center)
        
        if let camera = cameraNode.camera {
            camera.fieldOfView = 50
        }
        
        print("[frameCameraToContent] ✅ Successfully framed content. Center: \(center), Radius: \(radius)")
    }
    
    // MARK: - Export (USDZ + SCN)
    
    /// Exports the current (modified) scene to USDZ (recommended) or SCN format.
    /// - Parameters:
    ///   - baseName: Base filename without extension
    ///   - format: "usdz" (default, modern) or "scn"
    func exportScene(as baseName: String, format: String = "usdz") -> URL? {
        guard !scene.rootNode.childNodes.isEmpty else {
            errorMessage = "Scene is empty — nothing to export."
            showError = true
            return nil
        }
        
        let cleanName = baseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let exportName = cleanName.hasSuffix(".\(format)") 
        ? cleanName 
        : "\(cleanName).\(format)"
        
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Could not access Documents directory."
            showError = true
            return nil
        }
        
        let destinationURL = documentsURL.appendingPathComponent(exportName)
        
        // Export options using raw keys
        var options: [String: Any]? = nil
        if format == "usdz" {
            options = ["SCNSceneExportOptionCompress": true]
        }
        
        let success = scene.write(
            to: destinationURL,
            options: options,
            delegate: nil,
            progressHandler: { progress, error, stop in
                print("Export progress: \(Int(progress * 100))%")
                if let error = error {
                    print("Export error: \(error.localizedDescription)")
                }
            }
        )
        
        if success {
            print("[exportScene] ✅ Successfully exported to: \(destinationURL.path)")
            return destinationURL
        } else {
            errorMessage = "Export failed for \(exportName). Make sure the file extension is .usdz or .scn."
            showError = true
            return nil
        }
    }
    
    // MARK: - Debug Helper
    func debugSceneHierarchy() {
        print("\n=== SCENE HIERARCHY DEBUG ===")
        scene.rootNode.enumerateChildNodes { node, _ in
            let name = node.name ?? "<unnamed>"
            let hasGeo = node.geometry != nil ? "YES" : "no"
            print("• \(name) | Geometry: \(hasGeo) | Children: \(node.childNodes.count)")
        }
    }
}
