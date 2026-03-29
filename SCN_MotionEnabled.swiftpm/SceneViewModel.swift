// SceneViewModel.swift
//  
//  

import SwiftUI
import SceneKit
import QuartzCore
import GLKit
import CoreMotion

final class SceneViewModel: ObservableObject {
    @Published var selectedShip: String = "fighter"
    @Published var combatScene = SCNScene()
    @Published var currentOrientation: SCNVector4 = SCNVector4(0, 0, 0, 1)
    @Published var shieldsEnabled: Bool = false {
        didSet {
            shieldsNode?.opacity = shieldsEnabled ? 0.1 : 0.0
        }
    }
    
    private let model: SceneModel
    private let motionManager = MotionManager()
    private var shipNode: SCNNode?
    private var shieldsNode: SCNNode?
    private var motionTask: Task<Void, Never>?
    
    init() {
        // Fixed: Use literal string to avoid self before stored properties
        model = SceneModel(shipName: "fighter")
        let sceneFileName = model.shipName.hasSuffix(".scn") ? model.shipName : model.shipName + ".scn"
        if let loaded = SCNScene(named: sceneFileName) {
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
    
    public func startMotion(updateInterval: TimeInterval = 1.0 / 60.0) {
        print("func startMotion()")
        print("updateInterval:  \(1.0 / updateInterval) frames per second.\n")
        
        if motionTask != nil { return }
        
        // Capture and reuse the stream returned by startUpdates()
        let stream = motionManager.startUpdates(updateInterval: updateInterval)
        guard let attitudeStream = motionManager.attitudeStream ?? Optional(stream) else {
            print("WARN: motion stream not available after startUpdates()")
            return
        }
        
        startMotionUpdates(stream: attitudeStream)
    }
    
    public func stopMotion() {
        print("func stopMotion()\n")
        motionTask?.cancel()
        motionTask = nil
        motionManager.stopUpdates()
    }
    
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
    
    private func setupScene() {
        let shields = ghostEffect()
        shieldsNode = shields
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = model.camera.position
        cameraNode.camera?.automaticallyAdjustsZRange = model.camera.automaticallyAdjustsZRange
        cameraNode.look(at: model.camera.lookAt)
        combatScene.rootNode.addChildNode(cameraNode)
        
        for lightConfig in model.ambientLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = lightConfig.type
            lightNode.light?.color = lightConfig.color
            lightNode.position = lightConfig.position
            combatScene.rootNode.addChildNode(lightNode)
        }
        
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
        
        let plane = SCNPlane(width: model.plane.width, height: model.plane.height)
        plane.firstMaterial?.isDoubleSided = model.plane.isDoubleSided
        plane.firstMaterial?.diffuse.contents = model.plane.materialColor
        plane.firstMaterial?.fresnelExponent = model.plane.fresnelExponent
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = model.plane.position
        planeNode.runAction(SCNAction.rotate(by: model.plane.rotationAngle, around: SCNVector3(1, 0, 0), duration: 0))
        
        shipNode = combatScene.rootNode
        // Apply pi radians rotation about z-axis for 'fighter' only
        if model.shipName == "fighter" {
            shipNode?.orientation = SCNVector4(0, 0, 1, 0)  // pi radians about z-axis
        } else {
            shipNode?.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        }
        shipNode?.geometry?.firstMaterial?.isDoubleSided = true
        if let materials = shipNode?.geometry?.materials {
            for material in materials {
                print("material:  \(String(describing: material.name))")
                print("material.isDoubleSided: \(material.isDoubleSided)")
            }
            print()
        }
        shipNode?.addChildNode(planeNode)
        shipNode?.addChildNode(cabinLightNode)
        shipNode?.addChildNode(shields)
        
        for lightConfig in model.engineLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = lightConfig.type
            lightNode.light?.color = lightConfig.color
            if let intensity = lightConfig.intensity {
                lightNode.light?.intensity = intensity
            }
            lightNode.light?.castsShadow = lightConfig.castsShadow
            if let attenuation = lightConfig.attenuationEndDistance {
                lightNode.light?.attenuationEndDistance = attenuation
            }
            lightNode.position = lightConfig.position
            shipNode?.addChildNode(lightNode)
        }
        
        shieldsNode?.opacity = shieldsEnabled ? 0.1 : 0.0  // Updated: Use 0.1 for semi-transparent shields
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
    
    private func startMotionUpdates(stream: AsyncThrowingStream<AttitudeQuaternion, Error>) {
        if motionTask != nil { return }
        
        motionTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                for try await att in stream {
                    let x = att.x
                    let y = att.y
                    let z = att.z
                    let w = att.w
                    let mag = sqrt(x * x + y * y + z * z + w * w)
                    let nx = mag > 0 ? x / mag : x
                    let ny = mag > 0 ? y / mag : y
                    let nz = mag > 0 ? z / mag : z
                    let nw = mag > 0 ? w / mag : w
                    
                    await MainActor.run {
                        self.shipNode?.orientation = SCNVector4(nx, ny, nz, nw)
                        self.currentOrientation = SCNVector4(nx, ny, nz, nw)
                        print("currentOrientation:  \(self.currentOrientation)\n")
                    }
                }
            } catch {
                print("Motion stream error: \(error)")
            }
        }
    }
    
    func changeShip(to shipName: String) {
        model.shipName = shipName
        selectedShip = shipName
        let sceneFileName = model.shipName.hasSuffix(".scn") ? model.shipName : model.shipName + ".scn"
        if let loaded = SCNScene(named: sceneFileName) {
            combatScene = loaded
        } else {
            combatScene = SCNScene()
            print("WARN: \(sceneFileName) not found — using empty scene")
        }
        setupScene()
    }
}
