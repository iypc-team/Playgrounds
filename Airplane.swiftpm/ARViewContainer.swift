//  ARViewContainer.swift
//  
//  

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    let airplaneEntity: ModelEntity
    let viewModel: AirplaneViewModel
    @Binding var isTargetRotating: Bool
    let onContactEvent: (String) -> Void
    
    let cameraTranslation: SIMD3<Float>
    let lookAtTarget: SIMD3<Float>
    let cameraFromPosition: SIMD3<Float>
    
    init(
        airplaneEntity: ModelEntity,
        viewModel: AirplaneViewModel,
        isTargetRotating: Binding<Bool>,
        onContactEvent: @escaping (String) -> Void,
        cameraTranslation: SIMD3<Float> = SIMD3<Float>(-5, 0, 0),
        lookAtTarget: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        cameraFromPosition: SIMD3<Float> = SIMD3<Float>(-12, 12, 0)
    ) {
        self.airplaneEntity = airplaneEntity
        self.viewModel = viewModel
        self._isTargetRotating = isTargetRotating
        self.onContactEvent = onContactEvent
        self.cameraTranslation = cameraTranslation
        self.lookAtTarget = lookAtTarget
        self.cameraFromPosition = cameraFromPosition
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        let anchor = AnchorEntity(world: .zero)
        airplaneEntity.name = "airplane"
        
        airplaneEntity.components.set(
            CollisionComponent(
                shapes: [ShapeResource.generateConvex(from: airplaneEntity.model!.mesh)],
                mode: .default
            )
        )
        anchor.addChild(airplaneEntity)
        
        // ✅ Radar entity: load a Cone.usdz from Resources (iOS 16-compatible)
        Task {
            do {
                let radarEntity = try await Entity(named: "Cone") as! ModelEntity
//                let radarEntity = try await ModelEntity(named: "Cone")
                let radarMaterial = SimpleMaterial(color: UIColor.red, roughness: 0.0, isMetallic: false)
                radarEntity.model?.materials = [radarMaterial]
                
                radarEntity.position = SIMD3<Float>(0, 1, 0)
                radarEntity.name = "radar"
                
                radarEntity.components.set(PhysicsBodyComponent(
                    massProperties: .default,
                    material: .default,
                    mode: .kinematic
                ))
                
                radarEntity.components.set(
                    CollisionComponent(
                        shapes: [ShapeResource.generateConvex(from: radarEntity.model!.mesh)],
                        mode: .default
                    )
                )
                
                airplaneEntity.addChild(radarEntity)
            } catch {
                print("❌ Failed to load Cone.usdz: \(error)")
            }
        }
        
        // Target entity
        let targetEntity = ModelEntity(mesh: .generateSphere(radius: 1.0))
        let targetEntityMaterial = SimpleMaterial(color: UIColor.red, roughness: 0.0, isMetallic: false)
        targetEntity.model?.materials = [targetEntityMaterial]
        
        let targetEntityPosition = SIMD3<Float>(4, 0, 0)
        targetEntity.position = targetEntityPosition
        targetEntity.name = "target"
        
        targetEntity.components.set(
            CollisionComponent(
                shapes: [.generateSphere(radius: 1.0)],
                mode: .trigger
            )
        )
        anchor.addChild(targetEntity)
        
        // Lights
        let light = DirectionalLight()
        light.light.intensity = 4000
        light.look(at: SIMD3<Float>(0, 0, 0),
                   from: SIMD3<Float>(1, 1, 1),
                   relativeTo: nil)
        anchor.addChild(light)
        
        let light2 = DirectionalLight()
        light2.light.intensity = 4000
        light2.look(at: SIMD3<Float>(0, 0, 0),
                    from: SIMD3<Float>(-1, 1, -1),
                    relativeTo: nil)
        anchor.addChild(light2)
        
        // Camera
        let camera = PerspectiveCamera()
        camera.transform.translation = cameraTranslation
        camera.look(at: lookAtTarget,
                    from: cameraFromPosition,
                    relativeTo: nil)
        anchor.addChild(camera)
        
        anchor.position = SIMD3<Float>(0, 0, 0)
        arView.scene.addAnchor(anchor)
        
        context.coordinator.targetRadius = length(targetEntityPosition - SIMD3<Float>(0, 0, 0))
        context.coordinator.targetAngle = atan2(targetEntityPosition.z, targetEntityPosition.x)
        
        arView.scene
            .subscribe(to: SceneEvents.Update.self) { _ in
                airplaneEntity.transform.rotation = viewModel.currentOrientation
                if context.coordinator.isTargetRotating {
                    context.coordinator.targetAngle += 0.016 * context.coordinator.targetSpeed
                    let radius = context.coordinator.targetRadius
                    let center = SIMD3<Float>(0, 0, 0)
                    targetEntity.transform.translation = center + SIMD3<Float>(
                        radius * cos(context.coordinator.targetAngle),
                        0,
                        radius * sin(context.coordinator.targetAngle)
                    )
                }
            }
            .store(in: &context.coordinator.cancellables)
        
        context.coordinator.onContactEvent = onContactEvent
        context.coordinator.physics.setup(in: arView) { text in
            context.coordinator.onContactEvent?(text)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.isTargetRotating = isTargetRotating
    }
    
    class Coordinator {
        var cancellables = Set<AnyCancellable>()
        let physics = PhysicsCoordinator()
        var onContactEvent: ((String) -> Void)?
        var targetAngle: Float = 0
        let targetSpeed: Float = 0.5
        var isTargetRotating: Bool = false
        var targetRadius: Float = 4.0
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
