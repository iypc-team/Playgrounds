// SceneViewModel.swift
// 
//  Inspect_SCN  05/16/2026
//  SceneViewModel.swift

import SwiftUI
import SceneKit

@MainActor
final class SceneViewModel: ObservableObject {
    
    @Published var scene: SCNScene
    @Published var sceneModel: SceneModel
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // Shared across all screens
    @Published var selectedFile: String = "smooth_ship1.scn"
    @Published var resourceFiles: [String] = []
    @Published var sceneRevision: Int = 0
    
    private let fallbackSceneFiles: [String] = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighterPBR.scn",
        "newFighter.scn",
        "pyramid.scn",
        "smooth_ship1.scn",
        "smooth_ship.scn",
        "sphere.scn"
    ]
    
    init() {
        self.scene = SCNScene()
        self.sceneModel = SceneModel()
        setupEmptyScene()
        sceneModel.setScene(self.scene)
    }
    
    // MARK: - Resource Discovery
    
    func loadResourceFiles() {
        var found = Set<String>(fallbackSceneFiles)
        
        if let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: nil) {
            urls.forEach { found.insert($0.lastPathComponent) }
        }
        if let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: "Resources") {
            urls.forEach { found.insert($0.lastPathComponent) }
        }
        if let bundleURL = Bundle.main.resourceURL {
            FileManager.default
                .enumerator(at: bundleURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)?
                .compactMap { $0 as? URL }
                .filter { $0.pathExtension.lowercased() == "scn" }
                .forEach { found.insert($0.lastPathComponent) }
        }
        if let rp = Bundle.main.resourcePath {
            let fm = FileManager.default
            (try? fm.contentsOfDirectory(atPath: rp))?
                .filter { $0.lowercased().hasSuffix(".scn") }
                .forEach { found.insert($0) }
            let sub = (rp as NSString).appendingPathComponent("Resources")
            if fm.fileExists(atPath: sub) {
                (try? fm.contentsOfDirectory(atPath: sub))?
                    .filter { $0.lowercased().hasSuffix(".scn") }
                    .forEach { found.insert($0) }
            }
        }
        
        resourceFiles = found.sorted()
        print("[loadResourceFiles] Found: \(resourceFiles)")
        
        if !resourceFiles.contains(selectedFile), let first = resourceFiles.first {
            selectedFile = first
        }
    }
    
    // MARK: - Scene Loading
    
    @discardableResult
    func loadScene(for fileName: String) -> Bool {
        print("[loadScene] Loading '\(fileName)'")
        
        guard let loaded = loadSceneNamed(fileName) else {
            errorMessage = "Could not load scene: \(fileName)"
            showError = true
            return false
        }
        
        scene = loaded
        sceneModel = SceneModel()
        sceneModel.setScene(loaded)
        sceneRevision += 1
        setupScene()
        frameCameraToContent()
        print("[loadScene] ✅ '\(fileName)' loaded")
        return true
    }
    
    private func loadSceneNamed(_ fileName: String) -> SCNScene? {
        if let s = SCNScene(named: fileName) { return s }
        if let s = SCNScene(named: "Resources/\(fileName)") { return s }
        if let url = Bundle.main.url(
            forResource: fileName.replacingOccurrences(of: ".scn", with: ""),
            withExtension: "scn"
        ) {
            return try? SCNScene(url: url, options: nil)
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
            if let ref = node as? SCNReferenceNode, !ref.isLoaded { ref.load() }
        }
        
        let cam = SCNNode()
        cam.name = "appCamera"
        cam.camera = SCNCamera()
        cam.camera?.zNear = 0.01
        cam.camera?.zFar = 1000
        scene.rootNode.addChildNode(cam)
        
        let light = SCNLight()
        light.type = .directional
        light.intensity = 1800
        light.castsShadow = true
        let lightNode = SCNNode()
        lightNode.name = "appDirectionalLight"
        lightNode.light = light
        lightNode.position = SCNVector3(15, 25, 20)
        scene.rootNode.addChildNode(lightNode)
    }
    
    // MARK: - Camera Framing
    
    private func frameCameraToContent() {
        var geoNodes: [SCNNode] = []
        func collect(_ node: SCNNode) {
            if node.geometry != nil { geoNodes.append(node) }
            node.childNodes.forEach { collect($0) }
        }
        collect(scene.rootNode)
        
        var minV = SCNVector3(Float.infinity, Float.infinity, Float.infinity)
        var maxV = SCNVector3(-Float.infinity, -Float.infinity, -Float.infinity)
        var hasContent = false
        
        for node in geoNodes {
            let box = node.boundingBox
            guard box.min.x < box.max.x else { continue }
            let wMin = node.convertPosition(box.min, to: nil)
            let wMax = node.convertPosition(box.max, to: nil)
            minV.x = min(minV.x, wMin.x); minV.y = min(minV.y, wMin.y); minV.z = min(minV.z, wMin.z)
            maxV.x = max(maxV.x, wMax.x); maxV.y = max(maxV.y, wMax.y); maxV.z = max(maxV.z, wMax.z)
            hasContent = true
        }
        
        guard hasContent,
              let camNode = scene.rootNode.childNode(withName: "appCamera", recursively: true) else { return }
        
        let center = SCNVector3((minV.x + maxV.x) * 0.5, (minV.y + maxV.y) * 0.5, (minV.z + maxV.z) * 0.5)
        let radius = max(max(maxV.x - minV.x, maxV.y - minV.y), maxV.z - minV.z) * 0.6 + 3.0
        camNode.position = SCNVector3(center.x, center.y + radius * 0.7, center.z + radius * 1.4)
        camNode.look(at: center)
        camNode.camera?.fieldOfView = 50
    }
    
    // MARK: - Export
    
    func exportScene(as baseName: String, format: String = "usdz") -> URL? {
        guard !scene.rootNode.childNodes.isEmpty else {
            errorMessage = "Scene is empty — nothing to export."
            showError = true
            return nil
        }
        
        let dest: URL
        do {
            dest = try FileManagerService.shared.exportDestinationURL(for: baseName, format: format)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return nil
        }
        
        let ok = scene.write(to: dest, options: nil, delegate: nil) { p, e, _ in
            print("[export] \(Int(p * 100))%")
            if let e = e { print("[export] Error: \(e.localizedDescription)") }
        }
        
        guard ok else {
            errorMessage = "Export failed for \(dest.lastPathComponent)."
            showError = true
            return nil
        }
        
        print("✅ Exported: \(dest.path)")
        return dest
    }
    
    // MARK: - Debug
    
    func debugSceneHierarchy() {
        scene.rootNode.enumerateChildNodes { node, _ in
            print("• \(node.name ?? "<unnamed>") | geo: \(node.geometry != nil) | children: \(node.childNodes.count)")
        }
    }
}
