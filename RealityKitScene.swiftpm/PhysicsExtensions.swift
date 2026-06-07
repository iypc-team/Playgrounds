// PhysicsExtensions.swift

import RealityKit
import Foundation

extension Entity {
    
    func setupKinematicPhysics() {
        self.generateCollisionShapes(recursive: true)
        
        let physicsBody = PhysicsBodyComponent(
            massProperties: .default,
            material: .default,
            mode: .kinematic
        )
        
        self.components.set(physicsBody)
    }
    
    func highlightOnCollision() {
        let originalScale = self.scale
        self.scale = originalScale * 1.15
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.scale = originalScale
        }
    }
}
