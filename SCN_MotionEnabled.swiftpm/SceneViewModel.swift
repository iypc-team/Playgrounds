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
    
    init() {
        loadShip(named: selectedShip)
    }
    
    func loadShip(named name: String) {
        
        shipNode?.removeFromParentNode()
        
        guard let scene = SCNScene(named: "\(name).scn"),
              let node = scene.rootNode.childNodes.first else {
            return
        }
        
        shipNode = node
        self.scene.rootNode.addChildNode(node)
    }
    
    func toggleShields() {
        shieldsEnabled.toggle()
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
}

