// RealityKitView.swift
// Refactored: friendlyShip / enemyShip naming + weak capture safety

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
        // loadModels is @MainActor; makeUIView is also @MainActor via
        // UIViewRepresentable — direct synchronous call, no await needed.
        let (friendlyShip, enemyShip) = loadModels(into: anchor)
        setupLighting(anchor: anchor)
        let camera = setupCamera(anchor: anchor)
        
        arView.scene.addAnchor(anchor)
        
        context.coordinator.setupCollisionDetection(
            scene: arView.scene,
            entity: friendlyShip
        )
        setupAnimationLoop(
            arView: arView,
            coordinator: context.coordinator,
            friendlyShip: friendlyShip,
            enemyShip: enemyShip,
            camera: camera
        )
        
#if DEBUG
        print("RealityKit scene setup complete")
#endif
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
    
    /// @MainActor ensures all Entity property mutations (.name, .position,
    /// .orientation, .scale) satisfy RealityKit's actor isolation requirement.
    /// Entity.load(named:) is synchronous on iOS 16.6 — no async/await needed.
    @MainActor
    private func loadModels(into anchor: AnchorEntity) -> (Entity, Entity) {
        do {
#if DEBUG
            print("Loading models...")
#endif
            let friendlyShip = try Entity.load(named: "fighter")
            normalizeScale(friendlyShip)
            friendlyShip.setupKinematicPhysics()
            friendlyShip.name = "Friendly Ship"
            friendlyShip.position = SIMD3<Float>(-1.2, 0, 0)
            anchor.addChild(friendlyShip)
#if DEBUG
            print("Loaded Friendly Ship")
#endif
            
            let enemyShip = try Entity.load(named: "smooth_ship")
//            enemyShip.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0]) *
//            simd_quatf(angle: .pi, axis: [0, 1, 0])
            normalizeScale(enemyShip)
            enemyShip.setupKinematicPhysics()
            enemyShip.name = "Enemy Ship"
            enemyShip.position = SIMD3<Float>(1.8, 0.3, 0)
            anchor.addChild(enemyShip)
#if DEBUG
            print("Loaded Enemy Ship")
#endif
            
            return (friendlyShip, enemyShip)
            
        } catch {
#if DEBUG
            print("Failed to load models: \(error.localizedDescription). Using fallbacks.")
#endif
            let friendlyShip = ModelEntity(
                mesh: .generateBox(size: 0.6),
                materials: [SimpleMaterial(color: .orange, isMetallic: true)]
            )
            let enemyShip = ModelEntity(
                mesh: .generateBox(size: 0.7),
                materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
            )
            friendlyShip.setupKinematicPhysics()
            enemyShip.setupKinematicPhysics()
            friendlyShip.name = "Fallback Friendly Ship"
            enemyShip.name = "Fallback Enemy Ship"
            friendlyShip.position = SIMD3(-1.2, 0, 0)
            enemyShip.position = SIMD3(1.8, 0.3, 0)
            anchor.addChild(friendlyShip)
            anchor.addChild(enemyShip)
            return (friendlyShip, enemyShip)
        }
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
            
            // Fix #5: Enum case comparison instead of raw value.
            guard coordinator.rotationSpeed != .off else { return }
            
            let delta = Float(event.deltaTime) * coordinator.rotationSpeed.rawValue * 2.0
            
            coordinator.angle1      += delta
            coordinator.angle2      -= delta * 0.7
            coordinator.cameraAngle += Float(event.deltaTime) * 0.25
            
            friendlyShip.position = SIMD3(
                sin(coordinator.angle1) * 1.4,
                0.1 * sin(coordinator.angle1 * 2),
                cos(coordinator.angle1) * 1.4
            )
            enemyShip.position = SIMD3(
                sin(coordinator.angle2) * 2.0,
                0.4,
                cos(coordinator.angle2) * 2.0
            )
            
            let camRadius: Float = 4.8
            camera.position = SIMD3(
                sin(coordinator.cameraAngle) * camRadius,
                2.2,
                cos(coordinator.cameraAngle) * camRadius
            )
            camera.look(at: .zero, from: camera.position, relativeTo: nil)
        }
    }
    
    /// Normalises an entity's scale so its largest dimension fits within 0.85 units.
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
        var angle2: Float = 0
        var cameraAngle: Float = 0
        var rotationSpeed: RotationSpeed = .off
        var subscription: Cancellable?
        var collisionBeginSub: Cancellable?
        var collisionEndSub: Cancellable?
        
        func setupCollisionDetection(scene: RealityKit.Scene, entity: Entity) {
            collisionBeginSub = scene.subscribe(to: CollisionEvents.Began.self, on: entity) { event in
                let other = (event.entityA == entity) ? event.entityB : event.entityA
#if DEBUG
                print("PHYSICS COLLISION BEGAN: \"\(entity.name)\" ↔ \"\(other.name)\"")
#endif
                entity.highlightOnCollision()
                other.highlightOnCollision()
            }
            
            collisionEndSub = scene.subscribe(to: CollisionEvents.Ended.self, on: entity) { event in
                let other = (event.entityA == entity) ? event.entityB : event.entityA
#if DEBUG
                print("PHYSICS COLLISION ENDED: \"\(entity.name)\" ↔ \"\(other.name)\"")
#endif
            }
        }
    }
}
