//  PhysicsCoordinator.swift
// 

import RealityKit
import Combine

/// Owns physics/contact subscriptions so they stay alive for the lifetime of the ARView.
final class PhysicsCoordinator {
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Call once after entities are added to the scene/anchor.
    func setup(in arView: ARView) {
        // Subscribe to collision began — no console printing.
        arView.scene
            .subscribe(to: CollisionEvents.Began.self) { event in
                // Example: only react to cone <-> target contact, but don't print.
                let isConeTarget =
                (event.entityA.name == "cone" && event.entityB.name == "target") ||
                (event.entityA.name == "target" && event.entityB.name == "cone")
                
                guard isConeTarget else { return }
                
                // Do something silent here if you want:
                // - set a flag in your view model
                // - trigger a sound/haptic
                // - change material color, etc.
            }
            .store(in: &cancellables)
        
        arView.scene
            .subscribe(to: CollisionEvents.Ended.self) { event in
                let isConeTarget =
                (event.entityA.name == "cone" && event.entityB.name == "target") ||
                (event.entityA.name == "target" && event.entityB.name == "cone")
                
                guard isConeTarget else { return }
                // Silent end handling
            }
            .store(in: &cancellables)
    }
}
