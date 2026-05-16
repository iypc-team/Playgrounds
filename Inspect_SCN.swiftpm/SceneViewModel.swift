// SceneViewModel.swift
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
        self.sceneModel = SceneModel()
        setupEmptyScene()
        sceneModel.setScene(self.scene)
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
        self.sceneModel = SceneModel()
        sceneModel.setScene(loadedScene)
        
        print("[loadScene] ✅ Loaded '\(fileName)' from bundle")
        
        setupScene()
        frameCameraToContent()
        
        return true
    }
    
    private func loadSceneNamed(_ fileName: String) -> SCNScene? {
        if let scene = SCNScene(named: fileName) { return scene }
        if let scene = SCNScene(named: "Resources/\(fileName)") { return scene }
        
        if let url = Bundle.main.url(
            forResource: fileName.replacingOccurrences(of: ".scn", with: ""),
            withExtension: "scn"
        ) {
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
        scene.rootNode.childNode(withName: "appCamera", recursively: true)?.removeFromParentNode()
        scene.rootNode.childNode(withName: "appDirectionalLight", recursively: true)?.removeFromParentNode()
        
        scene.rootNode.enumerateChildNodes { node, _ in
            if let refNode = node as? SCNReferenceNode, !refNode.isLoaded {
                refNode.load()
                print("[setupScene] Forced load of SCNReferenceNode: \(node.name ?? "unnamed")")
            }
        }
        
        let cameraNode = SCNNode()
        cameraNode.name = "appCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 1000
        scene.rootNode.addChildNode(cameraNode)
        
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
            if node.geometry != nil { allGeometryNodes.append(node) }
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
        
        guard hasValidContent else {
            print("[frameCameraToContent] ⚠️ No valid geometry found — keeping default camera.")
            return
        }
        
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
        
        cameraNode.position = SCNVector3(
            center.x,
            center.y + radius * 0.7,
            center.z + radius * 1.4
        )
        cameraNode.look(at: center)
        cameraNode.camera?.fieldOfView = 50
        
        print("[frameCameraToContent] ✅ Framed content. Center: \(center), Radius: \(radius)")
    }
    
    // MARK: - Export
    
    /// Exports the current scene to the Documents/Exports/ folder.
    /// All path resolution and directory creation is handled by FileManagerService.
    /// - Parameters:
    ///   - baseName: Source file name (any extension stripped automatically)
    ///   - format: "usdz" (default) or "scn"
    /// - Returns: The destination URL on success, nil on failure
    func exportScene(as baseName: String, format: String = "usdz") -> URL? {
        guard !scene.rootNode.childNodes.isEmpty else {
            errorMessage = "Scene is empty — nothing to export."
            showError = true
            return nil
        }
        
        // Delegate all path logic to FileManagerService
        let destinationURL: URL
        do {
            destinationURL = try FileManagerService.shared.exportDestinationURL(
                for: baseName,
                format: format
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return nil
        }
        
        // SceneKit infers compression from the .usdz extension automatically
        let success = scene.write(
            to: destinationURL,
            options: nil,
            delegate: nil,
            progressHandler: { progress, error, _ in
                print("[exportScene] Progress: \(Int(progress * 100))%")
                if let error = error {
                    print("[exportScene] Error: \(error.localizedDescription)")
                }
            }
        )
        
        if success {
            print("✅ EXPORT SUCCESSFUL")
            print("   File: \(destinationURL.lastPathComponent)")
            print("   Path: \(destinationURL.path)")
            print("   (Files → On My iPad → Your Playground → Exports)")
            return destinationURL
        } else {
            errorMessage = "Export failed for \(destinationURL.lastPathComponent)."
            showError = true
            return nil
        }
    }
    
    // MARK: - Debug
    
    func debugSceneHierarchy() {
        print("\n=== SCENE HIERARCHY DEBUG ===")
        scene.rootNode.enumerateChildNodes { node, _ in
            let name = node.name ?? "<unnamed>"
            let hasGeo = node.geometry != nil ? "YES" : "no"
            print("• \(name) | Geometry: \(hasGeo) | Children: \(node.childNodes.count)")
        }
    }
}
