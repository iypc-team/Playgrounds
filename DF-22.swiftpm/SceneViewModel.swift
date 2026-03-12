// SceneViewModel.swift
//  
// Handles scene creation, configuration, and business logic.
//  

import SwiftUI
import SceneKit
import QuartzCore
import GLKit
import CoreMotion  // Added for MotionManager integration

class SceneViewModel: ObservableObject {
    @Published var scene: SCNScene
    
    private let model = SceneModel()
    private let motionManager = MotionManager()  // Added MotionManager instance
    private var shipNode: SCNNode?  // Reference to the ship for rotation updates
    private var motionTask: Task<Void, Never>?  // Task for handling motion stream
    
    init() {
        scene = SCNScene(named: model.shipName + ".scn")!
        setupScene()
        // Removed automatic start of motion updates to allow button control
    }
    
    deinit {
        motionTask?.cancel()
        motionManager.stopUpdates()
    }
    
    public func startMotion() {
        if motionTask != nil { return }  // Already started
        motionManager.startUpdates()
        startMotionUpdates()
    }
    
    public func stopMotion() {
        motionTask?.cancel()
        motionTask = nil
        motionManager.stopUpdates()
    }
    
    func ghostEffect(scene: SCNScene) -> SCNNode {
        // https://stackoverflow.com/questions/43843110/ios-scenekit-add-fresnel-effect-to-material-transparency
        let sphere = SCNSphere(radius: 8)
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
        // material.diffuse.contents = UIColor.clear
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
        // Add camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = model.camera.position
        cameraNode.camera?.automaticallyAdjustsZRange = model.camera.automaticallyAdjustsZRange
        cameraNode.look(at: model.camera.lookAt)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add ambient lights
        for lightConfig in model.ambientLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = lightConfig.type
            lightNode.light!.color = lightConfig.color
            lightNode.position = lightConfig.position
            scene.rootNode.addChildNode(lightNode)
        }
        
        // Add engine lights
        for lightConfig in model.engineLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = lightConfig.type
            lightNode.light!.color = lightConfig.color
            lightNode.light!.intensity = lightConfig.intensity!
            lightNode.light!.castsShadow = lightConfig.castsShadow
            lightNode.light!.attenuationEndDistance = lightConfig.attenuationEndDistance!
            lightNode.position = lightConfig.position
            // Note: In original, these are added to ship later
        }
        
        // Add cabin light
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.light!.type = model.cabinLight.type
        cabinLightNode.light!.color = model.cabinLight.color
        cabinLightNode.light!.intensity = model.cabinLight.intensity!
        cabinLightNode.light!.castsShadow = model.cabinLight.castsShadow
        cabinLightNode.light!.attenuationEndDistance = model.cabinLight.attenuationEndDistance!
        cabinLightNode.position = model.cabinLight.position
        
        // Create plane
        let plane = SCNPlane(width: model.plane.width, height: model.plane.height)
        plane.firstMaterial?.isDoubleSided = model.plane.isDoubleSided
        plane.firstMaterial?.diffuse.contents = model.plane.materialColor
        plane.firstMaterial?.fresnelExponent = model.plane.fresnelExponent
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = model.plane.position
        planeNode.runAction(SCNAction.rotate(by: model.plane.rotationAngle, around: SCNVector3(1, 0, 0), duration: 0))
        
        // Retrieve and configure ship
        shipNode = scene.rootNode.childNode(withName: model.shipName, recursively: true)!
        shipNode!.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        shipNode!.geometry?.firstMaterial?.isDoubleSided = true
        
        // Add children to ship
        shipNode!.addChildNode(planeNode)
        shipNode!.addChildNode(cabinLightNode)
        // Add engine lights to ship (assuming from original context)
        for lightConfig in model.engineLights {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = lightConfig.type
            lightNode.light!.color = lightConfig.color
            lightNode.light!.intensity = lightConfig.intensity!
            lightNode.light!.castsShadow = lightConfig.castsShadow
            lightNode.light!.attenuationEndDistance = lightConfig.attenuationEndDistance!
            lightNode.position = lightConfig.position
            shipNode!.addChildNode(lightNode)
        }
        
        // Debug prints (kept for consistency, can be removed)
        print("\nship.pivot\n", shipNode!.pivot)
        print("ship.orientation: ", shipNode!.orientation)
    }
    
    private func startMotionUpdates() {
        motionTask = Task {
            do {
                for try await quaternion in motionManager.attitudeStream! {
                    // Update ship orientation on main thread
                    await MainActor.run {
                        shipNode?.orientation = SCNVector4(quaternion.quaternion.x, quaternion.quaternion.y, quaternion.quaternion.z, quaternion.quaternion.w)
                    }
                }
            } catch {
                print("Motion stream error: \(error)")
            }
        }
    }
}
