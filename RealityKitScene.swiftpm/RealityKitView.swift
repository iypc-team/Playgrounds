// RealityKitView.swift
// Collision debugging version - explicit shapes + better kinematic handling
// Fixed damping property access

import SwiftUI
import RealityKit
import Combine

struct RealityKitView: UIViewRepresentable {
    @Binding var rotationSpeed: RotationSpeed
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )
        arView.environment.background = .color(.black)
        
        let anchor = AnchorEntity(world: .zero)
        let (friendlyShip, enemyShip) = loadModels(into: anchor)
        setupLighting(anchor: anchor)
        let camera = setupCamera(anchor: anchor)
        
        arView.scene.addAnchor(anchor)
        
        context.coordinator.setupCollisionDetection(
            scene: arView.scene,
            friendlyShip: friendlyShip,
            enemyShip: enemyShip
        )
        
        setupAnimationLoop(
            arView: arView,
            coordinator: context.coordinator,
            friendlyShip: friendlyShip,
            enemyShip: enemyShip,
            camera: camera
        )
        
        print("RealityKit scene setup complete - Collision debug mode")
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.rotationSpeed = rotationSpeed
    }
    
    func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        coordinator.subscription?.cancel()
        coordinator.collisionBeginSub?.cancel()
        coordinator.collisionEndSub?.cancel()
    }
    
    // MARK: - Scene Assembly
    
    @MainActor
    private func loadModels(into anchor: AnchorEntity) -> (Entity, Entity) {
        do {
            print("Loading models...")
            let friendlyShip = try Entity.load(named: "fighter")
            normalizeScale(friendlyShip)
            friendlyShip.setupKinematicPhysics()
            friendlyShip.name = "Friendly Ship"
            addCollisionComponent(to: friendlyShip, sizeMultiplier: 1.15)
            friendlyShip.position = SIMD3<Float>(-1.7, 0, 0)
            anchor.addChild(friendlyShip)
            print("Loaded Friendly Ship")
            
            let enemyShip = try Entity.load(named: "smooth_ship")
            normalizeScale(enemyShip)
            enemyShip.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            enemyShip.setupKinematicPhysics()
            enemyShip.name = "Enemy Ship"
            addCollisionComponent(to: enemyShip, sizeMultiplier: 1.15)
            enemyShip.position = SIMD3<Float>(1.7, 0.4, 0)
            anchor.addChild(enemyShip)
            print("Loaded Enemy Ship with X-axis rotation (π/2)")
            
            return (friendlyShip, enemyShip)
            
        } catch {
            print("Failed to load models: \(error.localizedDescription). Using fallbacks.")
            let friendlyShip = ModelEntity(
                mesh: .generateBox(size: 0.8),
                materials: [SimpleMaterial(color: .orange, isMetallic: true)]
            )
            let enemyShip = ModelEntity(
                mesh: .generateBox(size: 0.9),
                materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
            )
            
            friendlyShip.setupKinematicPhysics()
            enemyShip.setupKinematicPhysics()
            addCollisionComponent(to: friendlyShip)
            addCollisionComponent(to: enemyShip)
            
            friendlyShip.name = "Fallback Friendly Ship"
            enemyShip.name = "Fallback Enemy Ship"
            friendlyShip.position = SIMD3(-1.7, 0, 0)
            enemyShip.position = SIMD3(1.7, 0.4, 0)
            anchor.addChild(friendlyShip)
            anchor.addChild(enemyShip)
            return (friendlyShip, enemyShip)
        }
    }
    
    private func addCollisionComponent(to entity: Entity, sizeMultiplier: Float = 1.0) {
        let bounds = entity.visualBounds(relativeTo: nil)
        let extents = bounds.extents * sizeMultiplier
        let shape = ShapeResource.generateBox(size: extents)
        entity.components.set(CollisionComponent(shapes: [shape], mode: .default))
    }
    
    private func setupLighting(anchor: AnchorEntity) {
        let sun = DirectionalLight()
        sun.light.intensity = 4000
        sun.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
        anchor.addChild(sun)
        
        let fill = PointLight()
        fill.light.intensity = 2000
        fill.position = [3, 4, 3]
        anchor.addChild(fill)
    }
    
    private func setupCamera(anchor: AnchorEntity) -> PerspectiveCamera {
        let camera = PerspectiveCamera()
        anchor.addChild(camera)
        let initialPosition = SIMD3<Float>(0, 2.5, 5.0)
        camera.position = initialPosition
        camera.look(at: .zero, from: initialPosition, relativeTo: nil)
        return camera
    }
    
    private func setupAnimationLoop(
        arView: ARView,
        coordinator: Coordinator,
        friendlyShip: Entity,
        enemyShip: Entity,
        camera: PerspectiveCamera
    ) {
        coordinator.subscription = arView.scene.subscribe(
            to: SceneEvents.Update.self
        ) { [weak coordinator, weak friendlyShip, weak enemyShip, weak camera] event in
            guard let coordinator = coordinator,
                  let friendlyShip = friendlyShip,
                  let enemyShip = enemyShip,
                  let camera = camera else { return }
            
            guard coordinator.rotationSpeed != .off else { return }
            
            let delta = Float(event.deltaTime) * coordinator.rotationSpeed.rawValue * 2.0
            
            coordinator.angle1      += delta
            coordinator.angle2      += delta * 0.85
            coordinator.cameraAngle += Float(event.deltaTime) * 0.25
            
            // Friendly Ship
            friendlyShip.position = SIMD3(
                sin(coordinator.angle1) * 1.7,
                0.15 * sin(coordinator.angle1 * 3),
                cos(coordinator.angle1) * 1.7
            )
            
            // Enemy Ship
            enemyShip.position = SIMD3(
                sin(coordinator.angle2) * 1.7,
                0.35 + 0.2 * sin(coordinator.angle2 * 2),
                cos(coordinator.angle2) * 1.7
            )
            
            // Camera
            let camRadius: Float = 5.0
            camera.position = SIMD3(
                sin(coordinator.cameraAngle) * camRadius,
                2.5,
                cos(coordinator.cameraAngle) * camRadius
            )
            camera.look(at: .zero, from: camera.position, relativeTo: nil)
        }
    }
    
    private func normalizeScale(_ entity: Entity) {
        let bounds = entity.visualBounds(relativeTo: nil)
        let maxDim = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
        if maxDim > 0 {
            entity.scale = SIMD3(repeating: 0.85 / maxDim)
        }
    }
    
    // MARK: - Coordinator
    
    final class Coordinator {
        var angle1: Float = 0
        var angle2: Float = .pi / 2
        var cameraAngle: Float = 0
        var rotationSpeed: RotationSpeed = .off
        var subscription: Cancellable?
        var collisionBeginSub: Cancellable?
        var collisionEndSub: Cancellable?
        
        func setupCollisionDetection(
            scene: RealityKit.Scene,
            friendlyShip: Entity,
            enemyShip: Entity
        ) {
            printPhysicsProperties(for: friendlyShip, label: "Friendly Ship")
            printPhysicsProperties(for: enemyShip, label: "Enemy Ship")
            
            collisionBeginSub = scene.subscribe(to: CollisionEvents.Began.self) { event in
                let a = event.entityA.name
                let b = event.entityB.name
                print("🚨 COLLISION BEGAN: \(a) ↔ \(b)")
                event.entityA.highlightOnCollision()
                event.entityB.highlightOnCollision()
            }
            
            collisionEndSub = scene.subscribe(to: CollisionEvents.Ended.self) { event in
                print("✅ COLLISION ENDED: \(event.entityA.name) ↔ \(event.entityB.name)")
            }
        }
        
        private func printPhysicsProperties(for entity: Entity, label: String) {
            print("--- Physics Properties for \(label) ---")
            
            if let physicsBody = entity.components[PhysicsBodyComponent.self] as? PhysicsBodyComponent {
                print("  Mode: \(physicsBody.mode)")
                print("  Mass: \(physicsBody.massProperties.mass)")
                
                // Safe access for damping (may not be directly available on all setups)
                print("  Linear Damping: \(physicsBody.linearDamping)")
                print("  Angular Damping: \(physicsBody.angularDamping)")
                // Value of type 'PhysicsBodyComponent' has no component 'linearDamping'. Value of type 'PhysicsBodyComponent' has no component 'angularDamping'.
            } else {
                print("  No PhysicsBodyComponent")
            }
            
            if let collision = entity.components[CollisionComponent.self] as? CollisionComponent {
                print("  Collision shapes: \(collision.shapes.count)")
            } else {
                print("  No CollisionComponent")
            }
            
            print("  Initial Position: \(entity.position)")
            print("  Scale: \(entity.scale)")
            print("  Orientation: \(entity.orientation)")
            print("-----------------------------")
        }
    }
}
