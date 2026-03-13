// SceneViewModel.swift
// Safe combatScene handling, no implicitly unwrapped optionals, fallback demo content when model missing,
// and robust motion stream consumption.
// print

import SwiftUI
import SceneKit
import QuartzCore
import GLKit
import CoreMotion  // MotionManager integration

final class SceneViewModel: ObservableObject {
    @Published var combatScene: SCNScene
    @Published var currentOrientation: SCNVector4 = SCNVector4(0, 0, 0, 1)  // Real-time orientation monitor
    @Published var shieldsEnabled: Bool = false
    
    private let model = SceneModel()
    private let motionManager = MotionManager()
    private var shipNode: SCNNode?               // Optional reference to ship node
    private var motionTask: Task<Void, Never>?   // Task for handling motion stream
    
    init() {
        if let loaded = SCNScene(named: model.shipName + ".scn") {
            combatScene = loaded
        } else {
            combatScene = SCNScene()
            print("WARN: \(model.shipName).scn not found — using empty scene")
        }
        setupScene()
        // Motion is started/stopped via public API (e.g., UI buttons)
    }
    
    deinit {
        motionTask?.cancel()
        motionManager.stopUpdates()
    }
    
    public func startMotion(updateInterval: TimeInterval = 1.0 / 30.0) {
        if motionTask != nil { return }  // Already started
        
        motionManager.startUpdates(updateInterval: updateInterval) // This should create attitudeStream
        
        guard let stream = motionManager.attitudeStream else {
            print("WARN: motion stream not available after startUpdates()")
            return
        }
        
        startMotionUpdates(stream: stream)
    }
    
    public func stopMotion() {
        motionTask?.cancel()
        motionTask = nil
        motionManager.stopUpdates()
    }
    
    // Creates a simple "ghost" SCNNode; no unused parameter.
    func ghostEffect() -> SCNNode {
        // https://stackoverflow.com/questions/43843110/ios-scenekit-add-fresnel-effect-to-material-transparency
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
        // Add a camera (safe to add even if the scene file already contains one; helpful for fallback)
        let cameraNode = SCNNode()
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
        
        // Create cabin light node (configure safely)
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
        
        // Create plane
        let plane = SCNPlane(width: model.plane.width, height: model.plane.height)
        plane.firstMaterial?.isDoubleSided = model.plane.isDoubleSided
        plane.firstMaterial?.diffuse.contents = model.plane.materialColor
        plane.firstMaterial?.fresnelExponent = model.plane.fresnelExponent
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = model.plane.position
        planeNode.runAction(SCNAction.rotate(by: model.plane.rotationAngle, around: SCNVector3(1, 0, 0), duration: 0))
        
        // Retrieve and configure ship safely (no force-unwrap)
        if let ship = combatScene.rootNode.childNode(withName: model.shipName, recursively: true) {
            shipNode = ship
            shipNode?.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            shipNode?.geometry?.firstMaterial?.isDoubleSided = true
            
            // Add children to ship
            shipNode?.addChildNode(planeNode)
            shipNode?.addChildNode(cabinLightNode)
            shipNode?.addChildNode(shields)
            
            // Add engine lights to ship (configure safely)
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
        } else {
            // Ship not found — attach items to root so scene still shows something useful
            print("WARN: ship node '\(model.shipName)' not found; attaching plane and lights to rootNode")
            //            combatScene.rootNode.addChildNode(planeNode)
            //            combatScene.rootNode.addChildNode(cabinLightNode)
            
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
                combatScene.rootNode.addChildNode(lightNode)
            }
            
            // Fallback demo geometry so UI shows something immediately
            addFallbackDemoContent()
        }
        
        // Optional debug prints (remove or gate behind debug flag as needed)
        if let ship = shipNode {
            let materials = ship.geometry?.materials
            print("materials: \(String(describing: materials?.debugDescription))")
        } else {
            print("combatScene.rootNode children:", combatScene.rootNode.childNodes.map { $0.name ?? "<anon>" })
        }
    }
    
    private func addFallbackDemoContent() {
        // Only add if a visible geometry isn't already present
        // Add a visible geometry so the view isn't empty
        let box = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.1)
        box.firstMaterial?.diffuse.contents = UIColor.systemTeal
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "debugBox"
        boxNode.position = SCNVector3(0, 0, 0)
        combatScene.rootNode.addChildNode(boxNode)
        
        // Add a light so the box is lit
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000
        lightNode.light = light
        lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
        combatScene.rootNode.addChildNode(lightNode)
        
        // Optional: animate the box so it's obvious something is happening
        let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 6))
        boxNode.runAction(spin)
    }
    
    private func startMotionUpdates(stream: AsyncThrowingStream<AttitudeQuaternion, Error>) {
        // Ensure we don't start a duplicate task
        if motionTask != nil { return }
        
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
                    
                    // Update ship orientation on main actor
                    await MainActor.run {
                        // Note: SceneKit's orientation is an SCNVector4. If you find the rotation
                        // behaves incorrectly, convert quaternion -> euler or apply coordinate changes here.
                        self.shipNode?.orientation = SCNVector4(nx, ny, nz, nw)
                        self.currentOrientation = SCNVector4(nx, ny, nz, nw)  // Update for real-time monitoring
                    }
                }
            } catch {
                print("Motion stream error: \(error)")
            }
        }
    }
}
