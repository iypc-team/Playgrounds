// SceneViewModel.swift

import SwiftUI
import SceneKit

class SceneViewModel: NSObject, ObservableObject, SCNPhysicsContactDelegate {
    
    @Published var sceneModel: SceneModel
    @Published var scene: SCNScene
    @Published var universeScene: SCNScene?
    @Published var isRotating: Bool = false
    @Published var isFighterRotating: Bool = false
    @Published var fighterNode: SCNNode?
    @Published var redTargetSphere: SCNNode?
    
    private var radarNode: SCNNode?
    private var rotationAction: SCNAction?
    
    // MARK: - Motion
    private let motionManager = MotionManager()
    private var motionTask: Task<Void, Never>?
    
    // MARK: - Physics Categories
    struct PhysicsCategory {
        static let radar:   Int = 1 << 0
        static let fighter: Int = 1 << 1
        static let target:  Int = 1 << 2
    }
    
    override init() {
        self.scene = SCNScene()
        self.sceneModel = SceneModel()
        super.init()
        
        loadAndSetupScene()
    }
    
    private func loadAndSetupScene() {
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene
        } else {
            print("⚠️ Failed to load scene: \(sceneModel.sceneName)")
        }
        
        setupUniverseScene()
        setupFighterNode()
        setupRadarNode()
        setupRedTargetSphere()
        setupLights()
        setupCamera()
        
        scene.physicsWorld.contactDelegate = self
    }
    
    // MARK: - Universe Background Scene
    private func setupUniverseScene() {
        let bgScene = SCNScene()
        bgScene.rootNode.addChildNode(Universe.createNode())
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        bgScene.rootNode.addChildNode(cameraNode)
        
        self.universeScene = bgScene
    }
    
    private func setupFighterNode() {
        guard let fighter = scene.rootNode.childNode(withName: "fighter", recursively: true) else {
            print("⚠️ Fighter node not found in scene")
            if let alt = scene.rootNode.childNode(withName: "Fighter", recursively: true) ??
                scene.rootNode.childNode(withName: "ship", recursively: true) {
                self.fighterNode = alt
                print("✅ Found fighter using alternative name")
            }
            return
        }
        
        fighter.scale = sceneModel.fighterScale
        
        fighter.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        fighter.physicsBody?.categoryBitMask = PhysicsCategory.fighter
        fighter.physicsBody?.contactTestBitMask = PhysicsCategory.radar | PhysicsCategory.target
        
        self.fighterNode = fighter
        print("✅ Fighter node successfully set up: \(fighter)")
    }
    
    private func setupRadarNode() {
        guard let fighter = fighterNode else { return }
        
        let radar = SCNNode()
        radar.geometry = SCNCone(topRadius: 0.2, bottomRadius: 12.0, height: 1024)
        
        if let material = radar.geometry?.firstMaterial {
            material.diffuse.contents = UIColor.white
            material.transparency = 0.1
            material.lightingModel = .constant
        }
        
        let offset = (radar.geometry!.boundingBox.max.y - radar.geometry!.boundingBox.min.y) / 2.0 + 8.0
        radar.position = SCNVector3(0, -offset, 0.25)
        
        radar.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        radar.physicsBody?.categoryBitMask = PhysicsCategory.radar
        radar.physicsBody?.contactTestBitMask = PhysicsCategory.fighter | PhysicsCategory.target
        
        fighter.addChildNode(radar)
        self.radarNode = radar
        
        rotationAction = SCNAction.repeatForever(
            SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 2.0)
        )
    }
    
    private func setupRedTargetSphere() {
        let node = RedTargetSphere.create()
        scene.rootNode.addChildNode(node)
        self.redTargetSphere = node
    }
    
    private func setupLights() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor.white
        ambient.light?.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambient)
        
        guard let fighter = fighterNode else { return }
        
        let cabinLight = SCNNode()
        cabinLight.light = SCNLight()
        cabinLight.position = SCNVector3(0, -3.5, 5.0)
        cabinLight.light?.type = .omni
        cabinLight.light?.color = sceneModel.cabinLightColor
        cabinLight.light?.intensity = sceneModel.cabinLightIntensity
        fighter.addChildNode(cabinLight)
        
        let engineLight = SCNNode()
        engineLight.light = SCNLight()
        engineLight.position = SCNVector3(0, 0, 0)
        engineLight.light?.type = .omni
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
    
    // MARK: - Radar Rotation Methods
    
    func startRotation() {
        guard let radar = radarNode, let action = rotationAction else { return }
        radar.removeAllActions()
        radar.runAction(action)
        isRotating = true
    }
    
    func stopRotation() {
        radarNode?.removeAllActions()
        isRotating = false
    }
    
    // MARK: - Fighter Motion Control
    func startFighterRotation() {
        guard !isFighterRotating else { return }
        isFighterRotating = true
        
        motionTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = await motionManager.makeAttitudeStream(
                    updateInterval: 1.0 / 60.0
                )
                for try await attitude in stream {
                    guard !Task.isCancelled else { break }
                    let q = attitude.quaternion
                    await MainActor.run {
                        self.fighterNode?.orientation = SCNQuaternion(
                            x: Float(q.x),
                            y: Float(q.y),
                            z: Float(q.z),
                            w: Float(q.w)
                        )
                    }
                }
            } catch MotionError.unavailable {
                print("⚠️ Device motion unavailable on this device.")
                await MainActor.run { self.isFighterRotating = false }
            } catch {
                print("⚠️ Motion stream error: \(error)")
                await MainActor.run { self.isFighterRotating = false }
            }
        }
        
        print("✅ Fighter motion control started (device attitude → orientation)")
    }
    
    func stopFighterRotation() {
        motionTask?.cancel()
        motionTask = nil
        Task { await motionManager.stopUpdates() }
        isFighterRotating = false
        print("🛑 Fighter motion control stopped")
    }
    
    // MARK: - SCNPhysicsContactDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.name == "RedTargetSphere" || contact.nodeB.name == "RedTargetSphere") &&
            (contact.nodeA == radarNode || contact.nodeB == radarNode) {
            print("🔴 Radar contacted Red Target Sphere!")
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {}
}
