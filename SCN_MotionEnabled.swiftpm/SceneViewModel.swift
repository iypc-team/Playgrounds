// SceneViewModel.swift
// 

import Foundation
import SceneKit

@MainActor
final class SceneViewModel: ObservableObject {
    
    @Published var selectedShip: String = "fighter"
    @Published var motionRunning = false
    @Published var shieldsEnabled = false
    
    let scene = SCNScene()
    
    private let motionManager = MotionManager()
    
    private var shipNode: SCNNode?
    private var ghostNode: SCNNode?
    
    init() {
        loadShip(named: selectedShip)
    }
    
    func loadShip(named name: String) {
        
        // Remove existing ship and ghost nodes
        shipNode?.removeFromParentNode()
        ghostNode?.removeFromParentNode()
        
        guard let scene = SCNScene(named: "\(name).scn"),
              let node = scene.rootNode.childNodes.first else {
            return
        }
        
        shipNode = node
        self.scene.rootNode.addChildNode(node)
        
        // Add ghost effect as a child of shipNode if shields are enabled
        if shieldsEnabled {
            ghostNode = ghostEffect()
            shipNode!.addChildNode(ghostNode!)
        }
    }
    
    func toggleShields() {
        shieldsEnabled.toggle()
        
        if shieldsEnabled {
            if ghostNode == nil {
                ghostNode = ghostEffect()
                shipNode?.addChildNode(ghostNode!)
            }
        } else {
            ghostNode?.removeFromParentNode()
            ghostNode = nil
        }
    }
    
    func resetOrientation() {
        stopMotion()
        shipNode?.orientation = SCNQuaternion(0,0,0,1)
    }
    
    func startMotion() {
        
        guard !motionRunning else { return }
        
        motionRunning = true
        
        Task {
            
            do {
                
                for try await q in motionManager.startUpdates() {
                    
                    updateShipRotation(q)
                }
                
            } catch {
                print("Motion error:", error)
            }
        }
    }
    
    func stopMotion() {
        motionRunning = false
        motionManager.stopUpdates()
        shipNode?.orientation = SCNQuaternion(0,0,0,1)
    }
    
    private func updateShipRotation(_ q: AttitudeQuaternion) {
        
        shipNode?.orientation = SCNQuaternion(
            q.x,
            q.y,
            q.z,
            q.w
        )
    }
    
    private func ghostEffect() -> SCNNode {
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
}
