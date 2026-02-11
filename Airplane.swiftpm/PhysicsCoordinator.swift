//  PhysicsCoordinator.swift
//  
//  

import Foundation
import RealityKit
import Combine

/// Owns physics/contact subscriptions so they stay alive for the lifetime of the ARView.
final class PhysicsCoordinator {
    
    private var cancellables = Set<AnyCancellable>()
    
    // Match the names you assign in code:
    // coneEntity.name = "cone"
    // targetEntity.name = "target"
    private let coneName = "cone"
    private let targetName = "target"
    
    /// Call once after entities are added to the scene/anchor.
    func setup(in arView: ARView, onEvent: @escaping (String) -> Void) {
        arView.scene
            .subscribe(to: CollisionEvents.Began.self) { [coneName, targetName] event in
                let a = event.entityA.name
                let b = event.entityB.name
                print("Collision BEGAN: \(a) <-> \(b)")
                
                guard self.isConeTargetPair(a, b, coneName: coneName, targetName: targetName) else {
                    return
                }
                
                // Identify the other entity and capture its world position
                let other = (event.entityA.name == coneName) ? event.entityB : event.entityA
                let worldPos = other.position(relativeTo: nil)
                
                DispatchQueue.main.async {
                    let message = "✅ Contact: \(a) ↔︎ \(b) @ world(\(worldPos.x), \(worldPos.y), \(worldPos.z))"
                    print(message)
                    onEvent(message)
                }
            }
            .store(in: &cancellables)
        
        arView.scene
            .subscribe(to: CollisionEvents.Ended.self) { [coneName, targetName] event in
                let a = event.entityA.name
                let b = event.entityB.name
                print("Collision ENDED: \(a) <-> \(b)")
                
                guard self.isConeTargetPair(a, b, coneName: coneName, targetName: targetName) else { return }
                
                let other = (event.entityA.name == coneName) ? event.entityB : event.entityA
                let worldPos = other.position(relativeTo: nil)
                
                DispatchQueue.main.async {
                    let message = "⛔️ Ended: \(a) ↔︎ \(b) @ world(\(worldPos.x), \(worldPos.y), \(worldPos.z))"
                    print(message)
                    onEvent(message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func isConeTargetPair(_ a: String, _ b: String, coneName: String, targetName: String) -> Bool {
        (a == coneName && b == targetName) || (a == targetName && b == coneName)
    }
}
