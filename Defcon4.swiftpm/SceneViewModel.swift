// SceneViewModel.swift
import SwiftUI
import SceneKit

class SceneViewModel: NSObject, ObservableObject, SCNPhysicsContactDelegate {
    
    @Published var sceneModel: SceneModel
    @Published var scene: SCNScene
    @Published var isRotating: Bool = false
    @Published var isFighterRotating: Bool = false
    @Published var fighterNode: SCNNode?
    
    private var radarNode: SCNNode?
    private var rotationAction: SCNAction?
    private var fighterRotationAction: SCNAction?
    
    // Collision categories
    private struct PhysicsCategory {
        static let radar: Int = 1 << 0
        static let fighter: Int = 1 << 1
    }
    
    private var setupComplete = false
    
    override init() {
        self.scene = SCNScene()
        self.sceneModel = SceneModel()
        super.init()
        
        loadAndSetupScene()
    }
    
    private func loadAndSetupScene() {
        // Load scene from asset
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene
        } else {
            print("⚠️ Failed to load scene: \(sceneModel.sceneName). Using empty scene.")
        }
        
        setupFighterNode()
        setupRadarNode()
        setupLights()
        setupCamera()
        
        // Physics world delegate
        scene.physicsWorld.contactDelegate = self
        
        setupComplete = true
    }
    
    private func setupFighterNode() {
        guard let fighter = scene.rootNode.childNode(withName: "fighter", recursively: true) else {
            print("⚠️ Fighter node not found in scene.")
            return
        }
        
        fighter.scale = sceneModel.fighterScale
        
        // Physics body
        fighter.physicsBody = SCNPhysicsBody(type: .kinematic,
                                             shape: SCNPhysicsShape(node: fighter, options: nil))
        fighter.physicsBody?.categoryBitMask = PhysicsCategory.fighter
        fighter.physicsBody?.contactTestBitMask = PhysicsCategory.radar
        
        self.fighterNode = fighter
    }
    
    private func setupRadarNode() {
        guard let fighter = fighterNode else { return }
        
        let radar = SCNNode()
        radar.geometry = SCNCone(topRadius: 0.2, bottomRadius: 10.0, height: 1024)
        
        if let material = radar.geometry?.firstMaterial {
            material.diffuse.contents = UIColor.white
            material.transparency = 0.1
            material.lightingModel = .constant
        }
        
        // Position radar relative to fighter
        let offset = (radar.geometry!.boundingBox.max.y - radar.geometry!.boundingBox.min.y) / 2.0 + 8.0
        radar.position = SCNVector3(0, -offset, 0.25)
        
        // Physics
        radar.physicsBody = SCNPhysicsBody(type: .kinematic,
                                           shape: SCNPhysicsShape(geometry: radar.geometry!, options: nil))
        radar.physicsBody?.categoryBitMask = PhysicsCategory.radar
        radar.physicsBody?.contactTestBitMask = PhysicsCategory.fighter
        
        fighter.addChildNode(radar)
        self.radarNode = radar
        
        // Pre-create repeatable action
        rotationAction = SCNAction.repeatForever(
            SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 2.0)
        )
    }
    
    private func setupLights() {
        // Ambient light
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor.white                  // ← Fixed here
        ambient.light?.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambient)
        
        guard let fighter = fighterNode else { return }
        
        // Cabin light (red)
        let cabinLight = SCNNode()
        cabinLight.light = SCNLight()
        cabinLight.position = SCNVector3(0, -3.5, 5.0)
        cabinLight.light?.type = .omni
        cabinLight.light?.castsShadow = false
        cabinLight.light?.attenuationStartDistance = 1.0
        cabinLight.light?.attenuationEndDistance = 5.0
        cabinLight.light?.color = sceneModel.cabinLightColor
        cabinLight.light?.intensity = sceneModel.cabinLightIntensity
        fighter.addChildNode(cabinLight)
        
        // Engine light (green)
        let engineLight = SCNNode()
        engineLight.light = SCNLight()
        engineLight.position = SCNVector3(0, 0, 0)
        engineLight.light?.type = .omni
        engineLight.light?.castsShadow = false
        engineLight.light?.attenuationStartDistance = 1.0
        engineLight.light?.attenuationEndDistance = 5.0
        engineLight.light?.color = sceneModel.engineLightColor
        engineLight.light?.intensity = sceneModel.engineLightIntensity
        fighter.addChildNode(engineLight)
    }
    
    private func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
    }
    
    // MARK: - Rotation Controls
    
    func startRotation() {
        guard !isRotating, let radar = radarNode, let action = rotationAction else { return }
        radar.runAction(action)
        isRotating = true
    }
    
    func stopRotation() {
        radarNode?.removeAllActions()
        isRotating = false
    }
    
    func startFighterRotation() {
        guard let fighter = fighterNode, !isFighterRotating else { return }
        let action = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 20)
        fighterRotationAction = SCNAction.repeatForever(action)
        fighter.runAction(fighterRotationAction!)
        isFighterRotating = true
    }
    
    func stopFighterRotation() {
        fighterNode?.removeAllActions()
        isFighterRotating = false
    }
    
    // MARK: - SCNPhysicsContactDelegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let isRadarContact = (contact.nodeA == radarNode && contact.nodeB == fighterNode) ||
        (contact.nodeA == fighterNode && contact.nodeB == radarNode)
        
        if isRadarContact {
            print("🚨 Radar contact with fighter detected!")
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let isRadarContact = (contact.nodeA == radarNode && contact.nodeB == fighterNode) ||
        (contact.nodeA == fighterNode && contact.nodeB == radarNode)
        
        if isRadarContact {
            print("Radar contact ended.")
        }
    }
}
