//  RealityKitView.swift
//  0.6

import SwiftUI
import RealityKit
import Combine

struct RealityKitView: UIViewRepresentable {
    @Binding var rotationSpeed: Float
    
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
        
        // MARK: - Airplane
        let airplane = try! Entity.load(named: "Airplane")
        normalize(airplane)
        airplane.position = SIMD3<Float>(-0.6, 0, 0)
        
        // MARK: - Spaceship
        let spaceship = try! Entity.load(named: "Spaceship")
        
        // Corrected initial orientation (valid axes)
        let spaceshipInitialOrientation =
        simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0)) *   // X
        simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) *   // Y
        simd_quatf(angle: 0.0, axis: SIMD3<Float>(0, 0, 1)) // Z
        
        spaceship.orientation = spaceshipInitialOrientation
        
        normalize(spaceship)
        spaceship.position = SIMD3<Float>(0.6, 0, 0)
        
        // MARK: - Lighting
        let sun = DirectionalLight()
        sun.light.intensity = 3_000
        sun.orientation = simd_quatf(
            angle: -.pi / 4,
            axis: SIMD3<Float>(1, 0, 0)
        )
        
        let fill = PointLight()
        fill.light.intensity = 3_000
        fill.position = SIMD3<Float>(2, 2, 2)
        
        // MARK: - Camera
        let camera = PerspectiveCamera()
        
        anchor.addChild(airplane)
        anchor.addChild(spaceship)
        anchor.addChild(sun)
        anchor.addChild(fill)
        anchor.addChild(camera)
        
        arView.scene.addAnchor(anchor)
        
        context.coordinator.subscription =
        arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            
            context.coordinator.angle +=
            Float(event.deltaTime) * context.coordinator.rotationSpeed
            
            let radius: Float = 2.5
            let x = sin(context.coordinator.angle) * radius
            let z = cos(context.coordinator.angle) * radius
            
            camera.position = SIMD3<Float>(x, 0.4, z)
            camera.look(
                at: .zero,
                from: camera.position,
                relativeTo: nil
            )
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.rotationSpeed = rotationSpeed
    }
    
    // MARK: - Normalize helper
    private func normalize(_ entity: Entity) {
        let bounds = entity.visualBounds(relativeTo: nil)
        entity.position = -bounds.center
        
        let maxDimension = max(
            bounds.extents.x,
            bounds.extents.y,
            bounds.extents.z
        )
        
        entity.scale = SIMD3(repeating: 1.0 / maxDimension)
    }
    
    final class Coordinator {
        var angle: Float = 0
        var rotationSpeed: Float = 0.0
        var subscription: Cancellable?
    }
}
