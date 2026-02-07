//  PhysicsCoordinator.swift
// 

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
    func setup(in arView: ARView) {
        arView.scene
            .subscribe(to: CollisionEvents.Began.self) { [coneName, targetName] event in
                // Debug: log everything so you can verify events are firing at all.
                print("Collision BEGAN: \(event.entityA.name) <-> \(event.entityB.name)")
                
                // Focused: coneEntity <-> targetEntity
                guard self.isConeTargetPair(event.entityA.name, event.entityB.name,
                                       coneName: coneName, targetName: targetName) else { return }
                
                print(">>> CONE hit TARGET (began)")
                // record collision here (increment counter, set flag, etc.)
            }
            .store(in: &cancellables)
        
        arView.scene
            .subscribe(to: CollisionEvents.Ended.self) { [coneName, targetName] event in
                print("Collision ENDED: \(event.entityA.name) <-> \(event.entityB.name)")
                
                guard self.isConeTargetPair(event.entityA.name, event.entityB.name,
                                       coneName: coneName, targetName: targetName) else { return }
                
                print("<<< CONE hit TARGET (ended)")
            }
            .store(in: &cancellables)
    }
    
    private func isConeTargetPair(_ a: String, _ b: String, coneName: String, targetName: String) -> Bool {
        (a == coneName && b == targetName) || (a == targetName && b == coneName)
    }
}
