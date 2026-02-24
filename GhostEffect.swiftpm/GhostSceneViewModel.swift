//  GhostSceneViewModel.swift
//  camera

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
    
    // Track Combine cancellables / other resources to clean up
    private var cancellables = Set<AnyCancellable>()
    
    init(sceneName: String = "fighter.scn") {
        loadScene(named: sceneName)
        configureScene()
    }
    
    deinit {
        // cleanupSceneResources will dispatch to main if needed
        cleanupSceneResources()
    }
    
    // Helper to ensure SceneKit / UI work runs on main:
    private func performOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async { work() }
        }
    }
    
    // MARK: - Scene loading (robust for Playgrounds / SwiftPM / app bundle)
    private func loadScene(named sceneName: String) {
        print("private func loadScene(named sceneName: String)")
        // Try a few strategies to locate the .scn resource
        // 1) If running as Swift Package, try Bundle.module
        if let s = loadSceneFromPackageResource(named: sceneName) {
            performOnMain {
                self.scene = s
                self.isSceneLoaded = true
            }
            return
        }
        
        // 2) Try SCNScene(named:) which looks in the main bundle / playground resources
        if let s = SCNScene(named: sceneName) {
            performOnMain {
                self.scene = s
                self.isSceneLoaded = true
            }
            return
        }
        
        // 3) Try Bundle.main url-based load (useful in some playground contexts)
        if let url = Bundle.main.url(forResource: (sceneName as NSString).deletingPathExtension,
                                     withExtension: (sceneName as NSString).pathExtension),
           let s = try? SCNScene(url: url, options: nil) {
            performOnMain {
                self.scene = s
                self.isSceneLoaded = true
            }
            return
        }
        
        // Fallback: empty scene
        performOnMain {
            self.scene = SCNScene()
            self.isSceneLoaded = false
        }
        print("GhostSceneViewModel: failed to locate \(sceneName); using empty scene.")
    }
    
#if SWIFT_PACKAGE
    private func loadSceneFromPackageResource(named sceneName: String) -> SCNScene? {
        print("private func loadSceneFromPackageResource(named sceneName: String)")
        // Bundle.module is only available for Swift packages
        // Use optional chaining so this file also compiles in Playgrounds/Xcode without package
        if let url = Bundle.module.url(forResource: (sceneName as NSString).deletingPathExtension,
                                       withExtension: (sceneName as NSString).pathExtension) {
            return try? SCNScene(url: url, options: nil)
        }
        return nil
    }
#else
    private func loadSceneFromPackageResource(named _: String) -> SCNScene? {
        print("private func loadSceneFromPackageResource(named _: String)")
        return nil
    }
#endif
    
    // MARK: - Scene configuration
    private func configureScene() {
        performOnMain {
            print("private func configureScene()")
            // Prepare ghost node but don't add by default
            self.ghostNode = self.makeGhostEffectNode()
            // If the scene already contains a camera node, prefer it.
            if let existingCamera = self.findFirstCameraNode(in: self.scene) {
                self.cameraNode = existingCamera
                // Ensure camera is attached to the root (some .scn files keep camera elsewhere)
                if existingCamera.parent == nil {
                    self.scene.rootNode.addChildNode(existingCamera)
                }
            } else {
                // Create a camera and place it so it can see most typical content
                self.cameraNode = SCNNode()
                self.cameraNode.name = "mainCamera"
                self.cameraNode.camera = SCNCamera()
                self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
                self.cameraNode.camera?.automaticallyAdjustsZRange = true
                self.scene.rootNode.addChildNode(self.cameraNode)
            }
            
            // Background / ambient lights
            let bgLight1 = self.makeLight(type: .omni, color: .gray, position: SCNVector3(0, 0, 100), intensity: 500 * 1)  //  default intensity: 500
            let bgLight2 = self.makeLight(type: .omni, color: .gray, position: SCNVector3(0, 0, -100), intensity: 500 * 1)  //  default intensity: 500
            self.scene.rootNode.addChildNode(bgLight1)
            self.scene.rootNode.addChildNode(bgLight2)
            
            // Engine & cabin lights (create but attach later)
            self.engineLightNode = self.makeLight(type: .omni, color: .systemGreen, position: SCNVector3(0, -2, 0), intensity: 10000, attenuationEndDistance: 4)  //  intensity: 10000
            self.engineLightNode2 = self.makeLight(type: .omni, color: .systemGreen, position: SCNVector3(0, 1.5, 0), intensity: 10000, attenuationEndDistance: 4)  //  intensity: 10000
            self.cabinLightNode = self.makeLight(type: .omni, color: .systemRed, position: SCNVector3(0, -3.9, 0), intensity: 10000, attenuationEndDistance: 4)  //  intensity: 1000
            
            // Ambient fill
            let ambient = self.makeLight(type: .ambient, color: .darkGray, position: SCNVector3Zero, intensity: 200)
            self.scene.rootNode.addChildNode(ambient)
            
            // Attempt to find the ship node(s).
            // Many .scn files won't name the top container "fighter" — handle common variations:
            self.shipNode = self.scene.rootNode.childNode(withName: "fighter", recursively: true)
            if self.shipNode == nil {
                // Prefer nodes that actually have geometry (less likely to pick camera/light-only nodes)
                self.shipNode = self.scene.rootNode.childNodes.first(where: { $0.geometry != nil })
            }
            
            // Attach lights to ship if present; otherwise attach to root so something is visible
            if let ship = self.shipNode {
                if let cabin = self.cabinLightNode { ship.addChildNode(cabin) }
                if let e1 = self.engineLightNode { ship.addChildNode(e1) }
                if let e2 = self.engineLightNode2 { ship.addChildNode(e2) }
                
                if let ghost = self.ghostNode {
                    if ghost.parent == nil { ship.addChildNode(ghost) }
                }
                // Small rotation animation so it's obvious something is in the scene
                //            ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8)))
            } else {
                if let cabin = self.cabinLightNode { self.scene.rootNode.addChildNode(cabin) }
                if let e1 = self.engineLightNode { self.scene.rootNode.addChildNode(e1) }
                if let e2 = self.engineLightNode2 { self.scene.rootNode.addChildNode(e2) }
            }
        }
    }
    
    private func findFirstCameraNode(in scene: SCNScene) -> SCNNode? {
        print("private func findFirstCameraNode(in scene: SCNScene)")
        return scene.rootNode.childNodes.first(where: { $0.camera != nil })
    }
    
    private func makeLight(type: SCNLight.LightType,
                           color: UIColor,
                           position: SCNVector3,
                           intensity: CGFloat = 1000,
                           attenuationEndDistance: CGFloat = 0) -> SCNNode {
        print("private func makeLight")
        let node = SCNNode()
        let light = SCNLight()
        light.type = type
        light.color = color
        light.intensity = intensity
        light.castsShadow = false
        if attenuationEndDistance > 0 {
            light.attenuationEndDistance = attenuationEndDistance
        }
        node.light = light
        node.position = position
        return node
    }
    
    private func makeGhostEffectNode() -> SCNNode {
        print("private func makeGhostEffectNode()")
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
    
    // MARK: - Cleanup
    private func cleanupSceneResources() {
        // Ensure all SceneKit modifications happen on the main thread.
        performOnMain {
            print("private func cleanupSceneResources()")
            
            // Stop actions/animations/particles and clear geometry/material resources
            self.scene.rootNode.enumerateChildNodes { node, _ in
                node.removeAllActions()
                node.removeAllParticleSystems()
                node.removeAllAnimations()
                
                if let geometry = node.geometry {
                    for material in geometry.materials {
                        // Clear typical material content slots to release images/textures
                        material.diffuse.contents = nil
                        material.normal.contents = nil
                        material.ambient.contents = nil
                        material.specular.contents = nil
                        material.emission.contents = nil
                        material.reflective.contents = nil
                    }
                    node.geometry = nil
                }
                
                // Detach node from scene graph to break strong references
                node.removeFromParentNode()
            }
            
            // Clear published scene on main thread so UI consumers see the change
            self.scene = SCNScene()
            self.isSceneLoaded = false
            
            // Clear stored references
            self.shipNode = nil
            self.ghostNode = nil
            self.engineLightNode = nil
            self.engineLightNode2 = nil
            self.cabinLightNode = nil
            
            // Cancel Combine subscriptions (if any were added)
            self.cancellables.forEach { $0.cancel() }
            self.cancellables.removeAll()
        }
    }
    
    // MARK: - Public API
    func addGhostEffect() {
        print("func addGhostEffect()")
        performOnMain {
            guard let ghost = self.ghostNode else { return }
            if let ship = self.shipNode {
                if ghost.parent == nil { ship.addChildNode(ghost) }
            } else {
                if ghost.parent == nil { self.scene.rootNode.addChildNode(ghost) }
            }
        }
    }
    
    func removeGhostEffect() {
        print("func removeGhostEffect() ")
        performOnMain {
            self.ghostNode?.removeFromParentNode()
        }
    }
    
    func toggleGhostEffect(_ enabled: Bool) {
        print("func toggleGhostEffect(_ enabled: Bool)")
        if enabled { addGhostEffect() } else { removeGhostEffect() }
    }
    
    func replaceScene(named sceneName: String) {
        print("func replaceScene(named sceneName: String) ")
        // Clean up the current scene's resources before loading a new one.
        // cleanupSceneResources will dispatch to main as needed.
        cleanupSceneResources()
        
        // Load the new scene (loadScene updates published scene on main)
        loadScene(named: sceneName)
        
        // Reconfigure on main thread once the scene has been set.
        performOnMain {
            self.shipNode = nil
            self.ghostNode = nil
            self.cameraNode = SCNNode()
            self.configureScene()
        }
    }
}
