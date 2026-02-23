//  GhostSceneViewModel.swift
// 

import Foundation
import SceneKit
import UIKit
import Combine

final class GhostSceneViewModel: ObservableObject {
    @Published private(set) var scene: SCNScene
    @Published private(set) var isSceneLoaded: Bool = false
    
    // Exposed so the SCNView can use it as pointOfView if needed
    private(set) var cameraNode: SCNNode?
    
    // Keep references for later toggles
    private var shipNode: SCNNode?
    private var ghostNode: SCNNode?
    private var engineLightNode: SCNNode?
    private var engineLightNode2: SCNNode?
    private var cabinLightNode: SCNNode?
    
    init(sceneName: String = "fighter.scn") {
        // load scene or create an empty one
        self.scene = SCNScene(named: sceneName) ?? SCNScene()
        self.isSceneLoaded = (SCNScene(named: sceneName) != nil)
        configureScene()
    }
    
    private func configureScene() {
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        cameraNode.camera?.automaticallyAdjustsZRange = true
        scene.rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode
        
        // Omni lights (background)
        let lightNode = makeLight(type: .omni, color: UIColor.gray, position: SCNVector3(0,0,100))
        scene.rootNode.addChildNode(lightNode)
        
        let lightNode2 = makeLight(type: .omni, color: UIColor.gray, position: SCNVector3(0,0,-100))
        scene.rootNode.addChildNode(lightNode2)
        
        // Engine lights (attached to ship if present)
        engineLightNode = makeLight(type: .omni, color: UIColor.green, position: SCNVector3(0,-2,0), intensity: 10000, attenuationEndDistance: 4)
        engineLightNode2 = makeLight(type: .omni, color: UIColor.green, position: SCNVector3(0,1.5,0), intensity: 10000, attenuationEndDistance: 4)
        
        // Cabin light
        cabinLightNode = makeLight(type: .omni, color: UIColor.red, position: SCNVector3(0,4.5,0), intensity: 1000, attenuationEndDistance: 4)
        
        // Ambient
        let ambientLightNode = makeLight(type: .ambient, color: UIColor.darkGray, position: SCNVector3Zero)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Optional plane for testing
        let plane = SCNPlane(width: 3, height: 2.1)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        plane.firstMaterial?.fresnelExponent = .infinity
        plane.firstMaterial?.isDoubleSided = true
        // We don't add the plane to the scene by default — it's there if you want to.
        
        // Retrieve ship if present and attach lights
        shipNode = scene.rootNode.childNode(withName: "fighter", recursively: true)
        
        if let ship = shipNode {
            if let cabin = cabinLightNode { ship.addChildNode(cabin) }
            if let engine1 = engineLightNode { ship.addChildNode(engine1) }
            if let engine2 = engineLightNode2 { ship.addChildNode(engine2) }
        } else {
            // Fallback: attach to root so something is visible
            if let cabin = cabinLightNode { scene.rootNode.addChildNode(cabin) }
            if let engine1 = engineLightNode { scene.rootNode.addChildNode(engine1) }
            if let engine2 = engineLightNode2 { scene.rootNode.addChildNode(engine2) }
        }
        
        // Animate ship
        shipNode?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8)))
        
        // Prepare ghost node but don't add by default
        ghostNode = makeGhostEffectNode()
        
        // Mark loaded
        objectWillChange.send()
    }
    
    private func makeLight(type: SCNLight.LightType, color: UIColor, position: SCNVector3, intensity: CGFloat = 1000, attenuationEndDistance: CGFloat = 0) -> SCNNode {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = type
        node.light!.color = color
        node.position = position
        node.light!.intensity = intensity
        node.light!.castsShadow = false
        if attenuationEndDistance > 0 {
            node.light!.attenuationEndDistance = attenuationEndDistance
        }
        return node
    }
    
    private func makeGhostEffectNode() -> SCNNode {
        // Fresnel-looking sphere
        let sphere = SCNSphere(radius: 8)
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.reflective.contents = UIColor(red: 0, green: 0.764, blue: 1, alpha: 1)
        material.reflective.intensity = 3
        material.transparent.contents = UIColor.black.withAlphaComponent(0.3)
        material.transparencyMode = .default
        material.fresnelExponent = 4
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
        return sphereNode
    }
    
    // Public API for the View / UI
    func addGhostEffect() {
        guard let ghost = ghostNode else { return }
        // Attach to ship if available, otherwise to root
        if let ship = shipNode {
            // avoid adding twice
            if ghost.parent == nil {
                ship.addChildNode(ghost)
            }
        } else {
            if ghost.parent == nil {
                scene.rootNode.addChildNode(ghost)
            }
        }
    }
    
    func removeGhostEffect() {
        ghostNode?.removeFromParentNode()
    }
    
    func toggleGhostEffect(_ enabled: Bool) {
        if enabled { addGhostEffect() } else { removeGhostEffect() }
    }
    
    // Allow runtime swapping of the scene (if you want)
    func replaceScene(named sceneName: String) {
        let newScene = SCNScene(named: sceneName) ?? SCNScene()
        self.scene = newScene
        // reset references and reconfigure
        shipNode = nil
        ghostNode = nil
        cameraNode = nil
        configureScene()
        objectWillChange.send()
    }
}
