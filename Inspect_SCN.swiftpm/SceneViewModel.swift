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
    
    // MARK: - Scene Setup
    
    func setupScene() {
        // Remove stale camera and light nodes to prevent accumulation across reloads
        scene.rootNode.childNodes.filter { $0.camera != nil }.forEach { $0.removeFromParentNode() }
        scene.rootNode.childNodes.filter { $0.light  != nil }.forEach { $0.removeFromParentNode() }
        
        addCamera()
        addLights()
        frameCameraToContent()
    }
    
    private func addCamera() {
        let cameraNode = SCNNode()
        cameraNode.name = "appCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func addLights() {
        // Ambient — broad base illumination
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light!.type = .ambient
        ambient.light!.color = UIColor.white
        ambient.light!.intensity = sceneModel.lightIntensity * 2
        scene.rootNode.addChildNode(ambient)
        
        // Omni front
        let omniFront = SCNNode()
        omniFront.light = SCNLight()
        omniFront.light!.type = .omni
        omniFront.light!.color = UIColor.darkGray
        omniFront.light!.intensity = sceneModel.omniLightIntensity * 1.5
        omniFront.position = SCNVector3(0, 10, 20)
        scene.rootNode.addChildNode(omniFront)
        
        // Omni back
        let omniBack = SCNNode()
        omniBack.light = SCNLight()
        omniBack.light!.type = .omni
        omniBack.light!.color = UIColor.darkGray
        omniBack.light!.intensity = sceneModel.omniLightIntensity * 1.5
        omniBack.position = SCNVector3(0, 10, -20)
        scene.rootNode.addChildNode(omniBack)
        
        // Directional — depth and shadows
        let directional = SCNNode()
        directional.light = SCNLight()
        directional.light!.type = .directional
        directional.light!.color = UIColor.white
        directional.light!.intensity = sceneModel.omniLightIntensity * 0.8
        directional.light!.castsShadow = true
        directional.eulerAngles = SCNVector3(-Float.pi / 4, 0, 0)
        scene.rootNode.addChildNode(directional)
    }
    
    // MARK: - Camera Auto-Framing
    
    /// Computes a bounding-sphere for all scene content and pulls the camera back
    /// far enough so every model is visible, regardless of its world-space size.
    private func frameCameraToContent() {
        let (minVec, maxVec) = scene.rootNode.boundingBox
        let size   = SCNVector3(maxVec.x - minVec.x, maxVec.y - minVec.y, maxVec.z - minVec.z)
        let center = SCNVector3((minVec.x + maxVec.x) / 2,
                                (minVec.y + maxVec.y) / 2,
                                (minVec.z + maxVec.z) / 2)
        let radius = sqrt(size.x * size.x + size.y * size.y + size.z * size.z) / 2
        
        guard radius > 0.001 else {
            print("[frameCameraToContent] Scene is empty — keeping default camera.")
            return
        }
        
        let distance = radius * 2.5
        
        if let cam = scene.rootNode.childNode(withName: "appCamera", recursively: false) {
            cam.position = SCNVector3(center.x, center.y, center.z + distance)
            cam.look(at: center)
            print("[frameCameraToContent] center=\(center) radius=\(radius) distance=\(distance)")
        }
        
        let omniNodes = scene.rootNode.childNodes.filter { $0.light?.type == .omni }
        if omniNodes.count >= 2 {
            omniNodes[0].position = SCNVector3(center.x, center.y + radius, center.z + distance)
            omniNodes[1].position = SCNVector3(center.x, center.y + radius, center.z - distance)
        }
    }
    
    // MARK: - Scene Loading
    
    @discardableResult
    func loadScene(for name: String) -> Bool {
        let stem = (name as NSString).deletingPathExtension
        let ext  = (name as NSString).pathExtension
        
        if let url = resolveURL(stem: stem, ext: ext, name: name) {
            print("[loadScene] Located '\(name)' at: \(url.path)")
            do {
                let loaded = try SCNScene(url: url, options: nil)
                self.scene = loaded
                sceneModel.sceneName = name
                sceneModel.setScene(loaded)
                setupScene()
                return true
            } catch {
                print("[loadScene] Failed to load '\(name)': \(error.localizedDescription)")
            }
        } else {
            print("[loadScene] Could not locate '\(name)' in the bundle.")
        }
        
        // Fall back to an empty scene so the viewer is never blank
        self.scene = SCNScene()
        sceneModel.sceneName = name
        sceneModel.setScene(self.scene)
        setupScene()
        return false
    }
    
    // MARK: - URL Resolution (4 strategies)
    
    private func resolveURL(stem: String, ext: String, name: String) -> URL? {
        // Strategy 0: Resources subdirectory
        if let url = Bundle.main.url(forResource: stem, withExtension: ext,
                                     subdirectory: "Resources") { return url }
        // Strategy 1: Top-level bundle URL
        if let url = Bundle.main.url(forResource: stem, withExtension: ext) { return url }
        // Strategy 2: Path-based (handles spaces better on some platforms)
        if let path = Bundle.main.path(forResource: stem, ofType: ext) {
            return URL(fileURLWithPath: path)
        }
        // Strategy 3: Recursive FileManager scan
        if let url = findFileInBundle(named: name) { return url }
        // Strategy 4: Direct path construction
        if let rp = Bundle.main.resourcePath {
            let subPath  = ((rp as NSString).appendingPathComponent("Resources") as NSString)
                .appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: subPath) {
                return URL(fileURLWithPath: subPath)
            }
            let topPath = (rp as NSString).appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: topPath) {
                return URL(fileURLWithPath: topPath)
            }
        }
        return nil
    }
    
    private func findFileInBundle(named fileName: String) -> URL? {
        guard let bundleURL = Bundle.main.resourceURL else { return nil }
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: bundleURL,
                                             includingPropertiesForKeys: nil,
                                             options: .skipsHiddenFiles) else { return nil }
        while let url = enumerator.nextObject() as? URL {
            if url.lastPathComponent == fileName { return url }
            if url.path.removingPercentEncoding?.components(separatedBy: "/").last == fileName {
                return url
            }
        }
        return nil
    }
}
