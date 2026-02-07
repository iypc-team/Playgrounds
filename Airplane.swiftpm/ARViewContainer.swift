//  ARViewContainer.swift
//
// 

import SwiftUI
import RealityKit
import ARKit
import Combine

/// A thin wrapper that gives SwiftUI access to an ARView.
struct ARViewContainer: UIViewRepresentable {
    // Explicitly tell UIViewRepresentable that the wrapped view is an ARView.
    typealias UIViewType = ARView
    /// The entity that should be displayed.
    let airplaneEntity: ModelEntity
    /// The view model to read orientation from.
    let viewModel: AirplaneViewModel
    /// Binding for scaling the entities.
    @Binding var scale: CGFloat
    
    func makeUIView(context: Context) -> ARView {
        // Create an ARView that does **not** start an AR session (cameraMode .nonAR).
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        let anchor = AnchorEntity(world: .zero) // Add the airplane model to the scene.
        airplaneEntity.name = "airplane"  // Set name for identification
        anchor.addChild(airplaneEntity)
        
        // Create the targetEntity as a sphere with radius 1
        let targetEntity = ModelEntity(mesh: .generateSphere(radius: 1.0))
        
        // Create a red material for the targetEntity
        let targetEntityMaterial = SimpleMaterial(color: .red, isMetallic: false)
        targetEntity.model?.materials = [targetEntityMaterial]
        
        // Add physics properties to the targetEntity (dynamic sphere)
        let physicsBody = PhysicsBodyComponent(shapes: [.generateSphere(radius: 1.0)], mass: 1.0, material: .default, mode: .dynamic)
        targetEntity.components.set(physicsBody)
        
        // Position the targetEntity (e.g., at (2, 0, 0))
        targetEntity.position = SIMD3<Float>(2, 0, 0)
        
        targetEntity.name = "target"  // Set name for identification
        // Add the targetEntity to the anchor
        anchor.addChild(targetEntity)
        
        // Add a directional light to illuminate the airplane
        let light = DirectionalLight()
        light.light.intensity = 4000  // Adjust intensity as needed
        light.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(1, 1, 1), relativeTo: nil)  // Position and orient the light
        anchor.addChild(light)
        
        let light2 = DirectionalLight()
        light2.light.intensity = 4000  // Adjust intensity as needed
        light2.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(-1, 1, -1), relativeTo: nil)  // Position and orient the second light differently
        anchor.addChild(light2)
        
        // Create a custom camera oriented to look down the negative Y-axis
        let camera = PerspectiveCamera()
        camera.transform.translation = SIMD3<Float>(0, 5, 0)  // Position camera above the scene
        camera.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(0, 5, 0), relativeTo: nil)  // Orient to look down the negative Y-axis
        anchor.addChild(camera)
        
        // Position the anchor to center the airplane at the origin
        anchor.position = SIMD3<Float>(0, 0, 0)
        
        arView.scene.addAnchor(anchor)
        
        // Subscribe to per‑frame updates and apply the latest orientation from the view model.
        arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            airplaneEntity.transform.rotation = viewModel.currentOrientation
        }.store(in: &context.coordinator.cancellables)
        
        // Subscribe to collision began events and check for cone-target contact
        arView.scene.subscribe(to: CollisionEvents.Began.self) { event in
            if (event.entityA.name == "cone" && event.entityB.name == "target") || 
                (event.entityA.name == "target" && event.entityB.name == "cone") {
                print("Cone entity made contact with target entity")
            }
        }.store(in: &context.coordinator.cancellables)
        
        // Optional: Subscribe to collision ended events
        arView.scene.subscribe(to: CollisionEvents.Ended.self) { event in
            if (event.entityA.name == "cone" && event.entityB.name == "target") || 
                (event.entityA.name == "target" && event.entityB.name == "cone") {
                print("Cone entity ended contact with target entity")
            }
        }.store(in: &context.coordinator.cancellables)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Apply scaling to the airplane entity (including its cone child)
        airplaneEntity.transform.scale = SIMD3<Float>(repeating: 3.0 * Float(scale))  // Multiply by initial scale
    }
    
    class Coordinator {
        var cancellables = Set<AnyCancellable>()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
