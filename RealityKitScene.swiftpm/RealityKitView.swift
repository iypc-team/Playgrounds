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
        
        var airplaneEntity: Entity?
        var spaceshipEntity: Entity?
        
        do {
            print("🔄 Loading models...")
            let airplane = try Entity.load(named: "fighter")
            normalize(airplane)
            airplane.setupKinematicPhysics()
            airplane.name = "Fighter Jet"
            airplane.position = SIMD3<Float>(-1.2, 0, 0)
            anchor.addChild(airplane)
            airplaneEntity = airplane
            print("✅ Loaded Fighter Jet")
            
            let spaceship = try Entity.load(named: "smooth_ship")
            let initialOrientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0]) *
            simd_quatf(angle: .pi, axis: [0, 1, 0])
            spaceship.orientation = initialOrientation
            
            normalize(spaceship)
            spaceship.setupKinematicPhysics()
            spaceship.name = "Spaceship"
            spaceship.position = SIMD3<Float>(1.8, 0.3, 0)
            anchor.addChild(spaceship)
            spaceshipEntity = spaceship
            print("✅ Loaded Spaceship")
            
        } catch {
            print("❌ Failed to load models: \(error.localizedDescription). Using fallbacks.")
            let fallback1 = ModelEntity(mesh: .generateBox(size: 0.6), materials: [SimpleMaterial(color: .orange, isMetallic: true)])
            let fallback2 = ModelEntity(mesh: .generateBox(size: 0.7), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
            
            fallback1.setupKinematicPhysics()
            fallback2.setupKinematicPhysics()
            fallback1.name = "Fallback Box 1"
            fallback2.name = "Fallback Box 2"
            fallback1.position = SIMD3(-1.2, 0, 0)
            fallback2.position = SIMD3(1.8, 0.3, 0)
            anchor.addChild(fallback1)
            anchor.addChild(fallback2)
            airplaneEntity = fallback1
            spaceshipEntity = fallback2
        }
        
        // Lighting
        let sun = DirectionalLight()
        sun.light.intensity = 4000
        sun.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
        anchor.addChild(sun)
        
        let fill = PointLight()
        fill.light.intensity = 2000
        fill.position = [3, 4, 3]
        anchor.addChild(fill)
        
        // Camera
        let camera = PerspectiveCamera()
        anchor.addChild(camera)
        
        arView.scene.addAnchor(anchor)
        
        // Initial camera position (critical fix)
        let initialCamPos = SIMD3<Float>(0, 2.5, 5.0)
        camera.position = initialCamPos
        camera.look(at: .zero, from: initialCamPos, relativeTo: nil)
        
        guard let airplane = airplaneEntity, let spaceship = spaceshipEntity else {
            return arView
        }
        
        context.coordinator.setupCollisionDetection(scene: arView.scene, entityA: airplane, entityB: spaceship)
        
        // Animation loop
        context.coordinator.subscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak coordinator = context.coordinator, weak camera] event in
            guard let coordinator = coordinator, let camera = camera else { return }
            guard coordinator.rotationSpeed.rawValue != 0 else { return }
            
            let delta = Float(event.deltaTime) * coordinator.rotationSpeed.rawValue * 2.0
            
            coordinator.angle1 += delta
            coordinator.angle2 -= delta * 0.7
            coordinator.cameraAngle += Float(event.deltaTime) * 0.25
            
            // Orbit models
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
            
            // Camera orbit
            let camRadius: Float = 4.8
            camera.position = SIMD3(
                sin(coordinator.cameraAngle) * camRadius,
                2.2,
                cos(coordinator.cameraAngle) * camRadius
            )
            camera.look(at: .zero, from: camera.position, relativeTo: nil)
        }
        
        print("🚀 RealityKit scene setup complete")
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
    
    private func normalize(_ entity: Entity) {
        let bounds = entity.visualBounds(relativeTo: nil)
        entity.position = -bounds.center
        let maxDim = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
        if maxDim > 0 {
            entity.scale = SIMD3(repeating: 0.85 / maxDim)
        }
    }
    
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
                print("💥 PHYSICS COLLISION BEGAN: \"\(entityA.name)\" ↔ \"\(other.name)\"")
                entityA.highlightOnCollision()
                other.highlightOnCollision()
            }
            
            collisionEndSub = scene.subscribe(to: CollisionEvents.Ended.self, on: entityA) { event in
                let other = (event.entityA == entityA) ? event.entityB : event.entityA
                print("✅ PHYSICS COLLISION ENDED: \"\(entityA.name)\" ↔ \"\(other.name)\"")
            }
        }
    }
}
