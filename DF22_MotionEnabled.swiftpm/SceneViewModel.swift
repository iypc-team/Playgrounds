// SceneViewModel.swift
// Safe combatScene handling, no implicitly unwrapped optionals, fallback demo content when model missing,
// and robust motion stream consumption.

import SwiftUI
import SceneKit
import QuartzCore
import CoreMotion

final class SceneViewModel: ObservableObject {
    @Published var combatScene: SCNScene
    @Published var currentOrientation: SCNVector4 = SCNVector4(0, 0, 0, 1)
    @Published private(set) var isMotionActive: Bool = false
    
    // Published Euler angles for UI orientation indicators
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    @Published var shieldsEnabled: Bool = false {
        didSet {
            shieldsNode?.opacity = shieldsEnabled ? 1.0 : 0.0
        }
    }
    
    private let model: SceneModel
    private let motionManager = MotionManager()
    private var shipNode: SCNNode?
    private var shieldsNode: SCNNode?
    private var motionTask: Task<Void, Never>?
    private let appCameraNodeName = "appCamera"
    
    @MainActor
    private func clearMotionState() {
        motionTask = nil
        isMotionActive = false
    }
    
    init() {
        model = SceneModel(shipName: SceneModel.defaultShipName)
        let sceneFileName = model.shipName.hasSuffix(".scn") ? model.shipName : model.shipName + ".scn"
        if let loaded = loadScene(named: sceneFileName) {
            combatScene = loaded
        } else {
            combatScene = SCNScene()
            print("WARN: \(sceneFileName) not found — using empty scene")
        }
        setupScene()
    }
    
    deinit {
        motionTask?.cancel()
        motionManager.stopUpdates()
    }
    
    @MainActor
    public func startMotion() {
        print("func startMotion()")
        
        if motionTask != nil { return }  // Already started
        
        motionManager.startUpdates()
        
        guard let stream = motionManager.attitudeStream else {
            print("WARN: motion stream not available after startUpdates()")
            return
        }
        
        startMotionUpdates(stream: stream)
    }
    
    @MainActor
    public func stopMotion() {
        print("func stopMotion()")
        motionTask?.cancel()
        motionTask = nil
        motionManager.stopUpdates()
        isMotionActive = false
        
        // Reset orientation when the motion stream is stopped
        resetOrientation()
    }
    
    func resetOrientation() {
        let identity = SCNVector4(0, 0, 0, 1)
        shipNode?.orientation = identity
        currentOrientation = identity
        roll = 0.0
        pitch = 0.0
        yaw = 0.0
        print("Orientation reset to neutral")
    }
    
    // Creates a simple "ghost" SCNNode for shield effect.
    func ghostEffect() -> SCNNode {
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
    
    private func makeLightNode(from config: SceneModel.LightConfig) -> SCNNode {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = config.type
        lightNode.light?.color = config.color
        if let intensity = config.intensity {
            lightNode.light?.intensity = intensity
        }
        lightNode.light?.castsShadow = config.castsShadow
        if let attenuation = config.attenuationEndDistance {
            lightNode.light?.attenuationEndDistance = attenuation
        }
        lightNode.position = config.position
        return lightNode
    }
    
    private func attachLightsAndChildren(
        to node: SCNNode,
        planeNode: SCNNode,
        cabinLightNode: SCNNode,
        shields: SCNNode
    ) {
        node.addChildNode(planeNode)
        node.addChildNode(cabinLightNode)
        node.addChildNode(shields)
        for lightConfig in model.engineLights {
            node.addChildNode(makeLightNode(from: lightConfig))
        }
    }
    
    private func setupScene() {
        // DEBUG: Print all child nodes to identify ship node names
        print("DEBUG: All child nodes in scene:")
        combatScene.rootNode.enumerateChildNodes { node, _ in
            print("  Node: \(node.name ?? "unnamed")")
        }
        print()
        
        let shields = ghostEffect()
        shieldsNode = shields
        
        // Add camera
        let cameraNode = SCNNode()
        cameraNode.name = appCameraNodeName
        cameraNode.camera = SCNCamera()
        cameraNode.position = model.camera.position
        cameraNode.camera?.automaticallyAdjustsZRange = model.camera.automaticallyAdjustsZRange
        cameraNode.look(at: model.camera.lookAt)
        combatScene.rootNode.addChildNode(cameraNode)
        
        // Add ambient lights
        for lightConfig in model.ambientLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = lightConfig.type
            lightNode.light?.color = lightConfig.color
            lightNode.position = lightConfig.position
            combatScene.rootNode.addChildNode(lightNode)
        }
        
        // Create cabin light node
        let cabinLightNode = SCNNode()
        let cabinLight = SCNLight()
        cabinLight.type = model.cabinLight.type
        cabinLight.color = model.cabinLight.color
        if let intensity = model.cabinLight.intensity {
            cabinLight.intensity = intensity
        }
        cabinLight.castsShadow = model.cabinLight.castsShadow
        if let attenuation = model.cabinLight.attenuationEndDistance {
            cabinLight.attenuationEndDistance = attenuation
        }
        cabinLightNode.light = cabinLight
        cabinLightNode.position = model.cabinLight.position
        
        // Create plane node
        let plane = SCNPlane(width: model.plane.width, height: model.plane.height)
        plane.firstMaterial?.isDoubleSided = model.plane.isDoubleSided
        plane.firstMaterial?.diffuse.contents = model.plane.materialColor
        plane.firstMaterial?.fresnelExponent = model.plane.fresnelExponent
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = model.plane.position
        planeNode.runAction(SCNAction.rotate(by: model.plane.rotationAngle, around: SCNVector3(1, 0, 0), duration: 0))
        
        // Derive node name from ship name
        let nodeName = model.getNodeName(for: model.shipName)
        
        if let ship = combatScene.rootNode.childNode(withName: nodeName, recursively: true) {
            // Named ship node found
            shipNode = ship
            shipNode?.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            shipNode?.geometry?.firstMaterial?.isDoubleSided = true
            logMaterials(for: shipNode)
            attachLightsAndChildren(to: ship, planeNode: planeNode, cabinLightNode: cabinLightNode, shields: shields)
            
        } else if combatScene.rootNode.geometry != nil {
            // No named node, but root has geometry — use root as ship
            shipNode = combatScene.rootNode
            shipNode?.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            shipNode?.geometry?.firstMaterial?.isDoubleSided = true
            logMaterials(for: shipNode)
            attachLightsAndChildren(to: combatScene.rootNode, planeNode: planeNode, cabinLightNode: cabinLightNode, shields: shields)
            
        } else {
            // Ship not found — attach to rootNode and show fallback demo content
            print("WARN: ship node '\(nodeName)' not found; attaching plane and lights to rootNode")
            shipNode = combatScene.rootNode
            attachLightsAndChildren(to: combatScene.rootNode, planeNode: planeNode, cabinLightNode: cabinLightNode, shields: shields)
            addFallbackDemoContent()
        }
        
        // Set initial shields opacity based on shieldsEnabled
        shieldsNode?.opacity = shieldsEnabled ? 1.0 : 0.0
    }
    
    private func logMaterials(for node: SCNNode?) {
        if let materials = node?.geometry?.materials {
            for material in materials {
                print("material:  \(String(describing: material.name))")
            }
            print()
        }
    }
    
    private func addFallbackDemoContent() {
        let box = SCNBox(width: 1, height: 10, length: 1, chamferRadius: 0.1)
        box.firstMaterial?.diffuse.contents = UIColor.gray
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "debugBox"
        boxNode.position = SCNVector3(0, 0, 0)
        combatScene.rootNode.addChildNode(boxNode)
        
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000
        lightNode.light = light
        lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
        combatScene.rootNode.addChildNode(lightNode)
        
        let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 6))
        boxNode.runAction(spin)
    }
    
    @MainActor
    private func startMotionUpdates(stream: AsyncThrowingStream<AttitudeQuaternion, Error>) {
        if motionTask != nil { return }
        isMotionActive = true
        
        motionTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                for try await att in stream {
                    // Normalize quaternion to avoid scale issues
                    let x = att.quaternion.x
                    let y = att.quaternion.y
                    let z = att.quaternion.z
                    let w = att.quaternion.w
                    let mag = sqrt(x * x + y * y + z * z + w * w)
                    let nx = mag > 0 ? x / mag : x
                    let ny = mag > 0 ? y / mag : y
                    let nz = mag > 0 ? z / mag : z
                    let nw = mag > 0 ? w / mag : w
                    
                    await MainActor.run {
                        self.shipNode?.orientation = SCNVector4(nx, ny, nz, nw)
                        self.currentOrientation = SCNVector4(nx, ny, nz, nw)
                        
                        self.roll = att.roll
                        self.pitch = att.pitch
                        self.yaw = att.yaw
                    }
                }
                await self.clearMotionState()
            } catch {
                if !(error is CancellationError) {
                    print("Motion stream error: \(error)")
                    await MainActor.run {
                        self.resetOrientation()
                    }
                }
                await self.clearMotionState()
            }
        }
    }
    
    @MainActor
    func changeShip(to shipName: String) {
        let wasMotionActive = motionTask != nil
        stopMotion()  // This now resets orientation
        
        let validatedShipName = SceneModel.availableShipNames.contains(shipName)
            ? shipName
            : SceneModel.defaultShipName
        if validatedShipName != shipName {
            print("WARN: Unsupported ship '\(shipName)'; falling back to \(validatedShipName)")
        }
        model.shipName = validatedShipName
        let sceneFileName = model.shipName.hasSuffix(".scn") ? model.shipName : model.shipName + ".scn"
        if let loaded = loadScene(named: sceneFileName) {
            combatScene = loaded
        } else {
            combatScene = SCNScene()
            print("WARN: \(sceneFileName) not found — using empty scene")
        }
        setupScene()
        
        if wasMotionActive { startMotion() }
    }
    
    private func loadScene(named sceneFileName: String) -> SCNScene? {
        if let scene = SCNScene(named: sceneFileName) {
            return scene
        }
        return SCNScene(named: "Resources/\(sceneFileName)")
    }
}
