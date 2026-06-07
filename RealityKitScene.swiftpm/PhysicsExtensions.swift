// PhysicsExtensions.swift

import RealityKit

extension Entity {
    
    // MARK: - Private Highlight State
    
    /// Tracks entities currently mid-highlight to prevent scale race conditions.
    private static var _isHighlighting: [ObjectIdentifier: Bool] = [:]
    private static var _baseScales: [ObjectIdentifier: SIMD3<Float>] = [:]
    
    // MARK: - Physics Setup
    
    func setupKinematicPhysics() {
        self.generateCollisionShapes(recursive: true)
        let physicsBody = PhysicsBodyComponent(
            massProperties: .default,
            material: .default,
            mode: .kinematic
        )
        self.components.set(physicsBody)
    }
    
    // MARK: - Collision Highlight
    
    /// Briefly scales the entity up 15% on collision.
    /// Thread-safe: all mutations run on the MainActor.
    /// Race-condition safe: re-entrant calls are ignored while an animation is in flight.
    func highlightOnCollision() {
        let id = ObjectIdentifier(self)
        Task { @MainActor [weak self] in
            guard let self = self else {
                Entity._isHighlighting.removeValue(forKey: id)
                Entity._baseScales.removeValue(forKey: id)
                return
            }
            // Skip if already animating to avoid capturing an inflated scale.
            guard Entity._isHighlighting[id] != true else { return }
            
            let base = self.scale
            Entity._baseScales[id] = base
            Entity._isHighlighting[id] = true
            self.scale = base * 1.15
            
            // 250 ms delay — no Foundation / DispatchQueue needed.
            try? await Task.sleep(nanoseconds: 250_000_000)
            
            self.scale = Entity._baseScales[id] ?? base
            Entity._isHighlighting.removeValue(forKey: id)
            Entity._baseScales.removeValue(forKey: id)
        }
    }
}
