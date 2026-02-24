//  GhostSceneViewModel.swift
//  

import Foundation
import SceneKit
import UIKit
import Combine

final class GhostSceneViewModel: ObservableObject {
    @Published private(set) var scene: SCNScene = SCNScene()
    @Published private(set) var isSceneLoaded: Bool = false
    
    // Exposed so the SCNView can use it as pointOfView if needed
    private(set) var cameraNode: SCNNode = SCNNode()
    
    // Keep references for later toggles
    private var shipNode: SCNNode?
    private var ghostNode: SCNNode?
    private var engineLightNode: SCNNode?
    private var engineLightNode2: SCNNode?
    private var cabinLightNode: SCNNode?
    
    init(sceneName: String = "fighter.scn") {
        loadScene(named: sceneName)
        configureScene()
    }
    
    // MARK: - Scene loading (robust for Playgrounds / SwiftPM / app bundle)
    private func loadScene(named sceneName: String) {
        // Try a few strategies to locate the .scn resource
        // 1) If running as Swift Package, try Bundle.module
        if let scene = loadSceneFromPackageResource(named: sceneName) {
            self.scene = scene
            self.isSceneLoaded = true
            return
        }
        
        // 2) Try SCNScene(named:) which looks in the main bundle / playground resources
        if let scene = SCNScene(named: sceneName) {
            self.scene = scene
            self.isSceneLoaded = true
            return
        }
        
        // 3) Try Bundle.main url-based load (useful in some playground contexts)
        if let url = Bundle.main.url(forResource: (sceneName as NSString).deletingPathExtension,
                                     withExtension: (sceneName as NSString).pathExtension),
           let scene = try? SCNScene(url: url, options: nil) {
            self.scene = scene
            self.isSceneLoaded = true
            return
        }
        
        // Fallback: empty scene
        self.scene = SCNScene()
        self.isSceneLoaded = false
        print("GhostSceneViewModel: failed to locate \(sceneName); using empty scene.")
    }
    
#if SWIFT_PACKAGE
    private func loadSceneFromPackageResource(named sceneName: String) -> SCNScene? {
        // Bundle.module is only available for Swift packages
        // Use optional chaining so this file also compiles in Playgrounds/Xcode without package
        if let url = Bundle.module.url(forResource: (sceneName as NSString).deletingPathExtension,
                                       withExtension: (sceneName as NSString).pathExtension) {
            return try? SCNScene(url: url, options: nil)
        }
        return nil
    }
#else
    private func loadSceneFromPackageResource(named _: String) -> SCNScene? { nil }
#endif
    
    // MARK: - Scene configuration
    private func configureScene() {
        // If the scene already contains a camera node, prefer it.
        if let existingCamera = findFirstCameraNode(in: scene) {
            cameraNode = existingCamera
            // Ensure camera is attached to the root (some .scn files keep camera elsewhere)
            if existingCamera.parent == nil {
                scene.rootNode.addChildNode(existingCamera)
            }
        } else {
            // Create a camera and place it so it can see most typical content
            cameraNode = SCNNode()
            cameraNode.name = "mainCamera"
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
            cameraNode.camera?.automaticallyAdjustsZRange = true
            scene.rootNode.addChildNode(cameraNode)
        }
        
        // Background / ambient lights
        let bgLight1 = makeLight(type: .omni, color: .gray, position: SCNVector3(0, 0, 100), intensity: 500)
        let bgLight2 = makeLight(type: .omni, color: .gray, position: SCNVector3(0, 0, -100), intensity: 500)
        scene.rootNode.addChildNode(bgLight1)
        scene.rootNode.addChildNode(bgLight2)
        
        // Engine & cabin lights (create but attach later)
        engineLightNode = makeLight(type: .omni, color: .systemGreen, position: SCNVector3(0, -2, 0), intensity: 10000, attenuationEndDistance: 4)
        engineLightNode2 = makeLight(type: .omni, color: .systemGreen, position: SCNVector3(0, 1.5, 0), intensity: 10000, attenuationEndDistance: 4)
        cabinLightNode = makeLight(type: .omni, color: .systemRed, position: SCNVector3(0, 4.5, 0), intensity: 1000, attenuationEndDistance: 4)
        
        // Ambient fill
        let ambient = makeLight(type: .ambient, color: .darkGray, position: SCNVector3Zero, intensity: 200)
        scene.rootNode.addChildNode(ambient)
        
        // Attempt to find the ship node(s).
        // Many .scn files won't name the top container "fighter" — handle common variations:
        shipNode = scene.rootNode.childNode(withName: "fighter", recursively: true)
        if shipNode == nil {
            // Look for any node that contains geometry and looks like a main model
            shipNode = scene.rootNode.childNodes.first(where: { node in
                return node.geometry != nil || !node.childNodes.isEmpty
            })
        }
        
        // Attach lights to ship if present; otherwise attach to root so something is visible
        if let ship = shipNode {
            if let cabin = cabinLightNode { ship.addChildNode(cabin) }
            if let e1 = engineLightNode { ship.addChildNode(e1) }
            if let e2 = engineLightNode2 { ship.addChildNode(e2) }
            
            // Small rotation animation so it's obvious something is in the scene
//            ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8)))
        } else {
            if let cabin = cabinLightNode { scene.rootNode.addChildNode(cabin) }
            if let e1 = engineLightNode { scene.rootNode.addChildNode(e1) }
            if let e2 = engineLightNode2 { scene.rootNode.addChildNode(e2) }
        }
        
        // Prepare ghost node but don't add by default
        ghostNode = makeGhostEffectNode()
        
        // Ensure published properties update on main thread for UI consumers
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func findFirstCameraNode(in scene: SCNScene) -> SCNNode? {
        return scene.rootNode.childNodes.first(where: { $0.camera != nil })
    }
    
    private func makeLight(type: SCNLight.LightType,
                           color: UIColor,
                           position: SCNVector3,
                           intensity: CGFloat = 1000,
                           attenuationEndDistance: CGFloat = 0) -> SCNNode {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = type
        node.light!.color = color
        node.light!.intensity = intensity
        node.light!.castsShadow = false
        if attenuationEndDistance > 0 {
            node.light!.attenuationEndDistance = attenuationEndDistance
        }
        node.position = position
        return node
    }
    
    private func makeGhostEffectNode() -> SCNNode {
        // Fresnel-like transparent shell (scale and radius tuned to typical model size)
        let sphere = SCNSphere(radius: 8)
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor.black
        material.metalness.contents = 0.0
        material.roughness.contents = 0.6
        material.reflective.contents = UIColor(red: 0, green: 0.764, blue: 1, alpha: 1)
        material.reflective.intensity = 1.2
        material.transparency = 0.35
        material.transparencyMode = .dualLayer
        material.fresnelExponent = 4
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.name = "ghostEffect"
        node.position = SCNVector3Zero
        node.opacity = 0.9
        return node
    }
    
    // MARK: - Public API
    func addGhostEffect() {
        guard let ghost = ghostNode else { return }
        if let ship = shipNode {
            if ghost.parent == nil { ship.addChildNode(ghost) }
        } else {
            if ghost.parent == nil { scene.rootNode.addChildNode(ghost) }
        }
    }
    
    func removeGhostEffect() {
        ghostNode?.removeFromParentNode()
    }
    
    func toggleGhostEffect(_ enabled: Bool) {
        if enabled { addGhostEffect() } else { removeGhostEffect() }
    }
    
    func replaceScene(named sceneName: String) {
        loadScene(named: sceneName)
        // Clear references and rebuild configuration for the new scene
        shipNode = nil
        ghostNode = nil
        cameraNode = SCNNode()
        configureScene()
    }
}
