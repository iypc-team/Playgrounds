// RealityKitView.swift

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
        let (airplaneEntity, spaceshipEntity) = loadModels(into: anchor)
        setupLighting(anchor: anchor)
        let camera = setupCamera(anchor: anchor)
        
        arView.scene.addAnchor(anchor)
        
        context.coordinator.setupCollisionDetection(
            scene: arView.scene,
            entityA: airplaneEntity,
            entityB: spaceshipEntity
        )
        setupAnimationLoop(
            arView: arView,
            coordinator: context.coordinator,
            airplane: airplaneEntity,
            spaceship: spaceshipEntity,
            camera: camera
        )
        
#if DEBUG
        print("🚀 RealityKit scene setup complete")
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
    
    private func loadModels(into anchor: AnchorEntity) -> (Entity, Entity) {
        do {
#if DEBUG
            print("🔄 Loading models...")
#endif
            
            let airplane = try Entity.load(named: "fighter")
            normalizeScale(airplane)
            airplane.setupKinematicPhysics()
            airplane.name = "Fighter Jet"
            airplane.position = SIMD3<Float>(-1.2, 0, 0)
            anchor.addChild(airplane)
#if DEBUG
            print("✅ Loaded Fighter Jet")
#endif
            
            let spaceship = try Entity.load(named: "smooth_ship")
            spaceship.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0]) *
            simd_quatf(angle: .pi,     axis: [0, 1, 0])
            normalizeScale(spaceship)
            spaceship.setupKinematicPhysics()
            spaceship.name = "Spaceship"
            spaceship.position = SIMD3<Float>(1.8, 0.3, 0)
            anchor.addChild(spaceship)
#if DEBUG
            print("✅ Loaded Spaceship")
#endif
            
            return (airplane, spaceship)
            
        } catch {
#if DEBUG
            print("❌ Failed to load models: \(error.localizedDescription). Using fallbacks.")
#endif
            
            let fallback1 = ModelEntity(
                mesh: .generateBox(size: 0.6),
                materials: [SimpleMaterial(color: .orange, isMetallic: true)]
            )
            let fallback2 = ModelEntity(
                mesh: .generateBox(size: 0.7),
                materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
            )
            fallback1.setupKinematicPhysics()
            fallback2.setupKinematicPhysics()
            fallback1.name = "Fallback Box 1"
            fallback2.name = "Fallback Box 2"
            fallback1.position = SIMD3(-1.2, 0, 0)
            fallback2.position = SIMD3(1.8, 0.3, 0)
            anchor.addChild(fallback1)
            anchor.addChild(fallback2)
            return (fallback1, fallback2)
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
        airplane: Entity,
        spaceship: Entity,
        camera: PerspectiveCamera
    ) {
        coordinator.subscription = arView.scene.subscribe(
            to: SceneEvents.Update.self
        ) { [weak coordinator, weak camera] event in
            guard let coordinator = coordinator, let camera = camera else { return }
            guard coordinator.rotationSpeed.rawValue != 0 else { return }
            
            let delta = Float(event.deltaTime) * coordinator.rotationSpeed.rawValue * 2.0
            
            coordinator.angle1      += delta
            coordinator.angle2      -= delta * 0.7
            coordinator.cameraAngle += Float(event.deltaTime) * 0.25
            
            airplane.position = SIMD3(
                sin(coordinator.angle1) * 1.4,
                0.1 * sin(coordinator.angle1 * 2),
                cos(coordinator.angle1) * 1.4
            )
            spaceship.position = SIMD3(
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
        
        func setupCollisionDetection(scene: RealityKit.Scene, entityA: Entity, entityB: Entity) {
            collisionBeginSub = scene.subscribe(to: CollisionEvents.Began.self, on: entityA) { event in
                let other = (event.entityA == entityA) ? event.entityB : event.entityA
#if DEBUG
                print("💥 PHYSICS COLLISION BEGAN: \"\(entityA.name)\" ↔ \"\(other.name)\"")
#endif
                entityA.highlightOnCollision()
                other.highlightOnCollision()
            }
            
            collisionEndSub = scene.subscribe(to: CollisionEvents.Ended.self, on: entityA) { event in
                let other = (event.entityA == entityA) ? event.entityB : event.entityA
#if DEBUG
                print("✅ PHYSICS COLLISION ENDED: \"\(entityA.name)\" ↔ \"\(other.name)\"")
#endif
            }
        }
    }
}
