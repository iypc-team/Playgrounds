//  ARViewContainer.swift
//  
//  


import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    // Explicitly tell UIViewRepresentable that the wrapped view is an ARView.
    typealias UIViewType = ARView
    
    /// The entity that should be displayed.
    let airplaneEntity: ModelEntity
    /// The view model to read orientation from.
    let viewModel: AirplaneViewModel
    /// Binding for scaling the entities.
    @Binding var scale: CGFloat
    /// Binding for toggling target rotation.
    @Binding var isTargetRotating: Bool
    /// Contact callback
    let onContactEvent: (String) -> Void
    
    /// Configurable camera translation (position offset).
    let cameraTranslation: SIMD3<Float>
    
    /// Configurable look-at target position.
    let lookAtTarget: SIMD3<Float>
    /// Configurable camera "from" position for look-at.
    let cameraFromPosition: SIMD3<Float>
    
    init(airplaneEntity: ModelEntity, viewModel: AirplaneViewModel, scale: Binding<CGFloat>, isTargetRotating: Binding<Bool>, onContactEvent: @escaping (String) -> Void, cameraTranslation: SIMD3<Float> = SIMD3<Float>(-5, 0, 0), lookAtTarget: SIMD3<Float> = SIMD3<Float>(0, 0, 0), cameraFromPosition: SIMD3<Float> = SIMD3<Float>(-6, 12, 0)) {
        self.airplaneEntity = airplaneEntity
        self.viewModel = viewModel
        self._scale = scale
        self._isTargetRotating = isTargetRotating
        self.onContactEvent = onContactEvent
        self.cameraTranslation = cameraTranslation
        self.lookAtTarget = lookAtTarget
        self.cameraFromPosition = cameraFromPosition
    }
    
    func makeUIView(context: Context) -> ARView {
        // Create an ARView that does **not** start an AR session (cameraMode .nonAR).
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        print("arView: \(arView)")
        
        let anchor = AnchorEntity(world: .zero) // Add the airplane model to the scene.
        airplaneEntity.name = "airplane"  // Set name for identification
        
        // Add collision component to airplaneEntity for collision detection
        airplaneEntity.components.set(
            CollisionComponent(
                shapes: [ShapeResource.generateConvex(from: airplaneEntity.model!.mesh)],
                mode: .default
            )
        )
        
        anchor.addChild(airplaneEntity)
        
        // Create the targetEntity as a sphere with radius 1
        let targetEntity = ModelEntity(mesh: .generateSphere(radius: 1.0))
        
        // Create a red material for the targetEntity
        let targetEntityMaterial = SimpleMaterial(color: .red, isMetallic: false)
        targetEntity.model?.materials = [targetEntityMaterial]
        
        // Position the targetEntity (e.g., at (2, 0, 0))
        targetEntity.position = SIMD3<Float>(2, 0, 0)
        targetEntity.name = "target"  // Set name for identification
        
        // Trigger-only collision for presence detection (no physical response)
        targetEntity.components.set(
            CollisionComponent(
                shapes: [.generateSphere(radius: 1.0)],
                mode: .trigger
            )
        )
        
        // Add the targetEntity to the anchor
        anchor.addChild(targetEntity)
        
        // Add a directional light to illuminate the airplane
        let light = DirectionalLight()
        light.light.intensity = 4000  // Adjust intensity as needed
        light.look(at: SIMD3<Float>(0, 0, 0),
                   from: SIMD3<Float>(1, 1, 1),
                   relativeTo: nil)
        anchor.addChild(light)
        
        let light2 = DirectionalLight()
        light2.light.intensity = 4000  // Adjust intensity as needed
        light2.look(at: SIMD3<Float>(0, 0, 0),
                    from: SIMD3<Float>(-1, 1, -1),
                    relativeTo: nil)
        anchor.addChild(light2)
        
        // Create a custom camera oriented to look down the negative Y-axis
        let camera = PerspectiveCamera()
        camera.transform.translation = cameraTranslation  // Configurable
        camera.look(at: lookAtTarget,  // Configurable
                    from: cameraFromPosition,  // Configurable
                    relativeTo: nil)
        anchor.addChild(camera)
        
        // Position the anchor to center the airplane at the origin
        anchor.position = SIMD3<Float>(0, 0, 0)
        
        arView.scene.addAnchor(anchor)
        
        // Subscribe to per‑frame updates and apply the latest orientation from the view model.
        arView.scene
            .subscribe(to: SceneEvents.Update.self) { _ in
                airplaneEntity.transform.rotation = viewModel.currentOrientation
                
                // Update targetEntity position for orbiting if enabled
                if context.coordinator.isTargetRotating {
                    context.coordinator.targetAngle += 0.016 * context.coordinator.targetSpeed
                    let radius: Float = 2.0  // Distance from the orbit center; adjust as needed
                    let center = SIMD3<Float>(0, 0, 0)  // Point to orbit about; change if needed
                    targetEntity.transform.translation = center + SIMD3<Float>(
                        radius * cos(context.coordinator.targetAngle),
                        0,
                        radius * sin(context.coordinator.targetAngle)
                    )
                }
            }
            .store(in: &context.coordinator.cancellables)
        
        // Hook up physics/contact handling with callback
        context.coordinator.onContactEvent = onContactEvent
        context.coordinator.physics.setup(in: arView) { text in
            context.coordinator.onContactEvent?(text)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Apply scaling to the airplane entity (including its cone child)
        airplaneEntity.transform.scale = SIMD3<Float>(repeating: 3.0 * Float(scale))  // Multiply by initial scale
        
        // Update the coordinator's rotation state
        context.coordinator.isTargetRotating = isTargetRotating
    }
    
    class Coordinator {
        var cancellables = Set<AnyCancellable>()
        let physics = PhysicsCoordinator()
        var onContactEvent: ((String) -> Void)?
        var targetAngle: Float = 0
        let targetSpeed: Float = 0.5  // Radians per second; adjust for speed
        var isTargetRotating: Bool = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
