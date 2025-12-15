// 
//  ARViewContainer.swift
//

import SwiftUI
import RealityKit
import ARKit
import Combine          // needed for AnyCancellable

/// A thin wrapper that gives SwiftUI access to an ARView.
struct ARViewContainer: UIViewRepresentable {
    // Explicitly tell UIViewRepresentable that the wrapped view is an ARView.
    typealias UIViewType = ARView
    /// The entity that should be displayed.
    let airplaneEntity: ModelEntity
    /// The view model to read orientation from.
    let viewModel: AirplaneViewModel
    
    func makeUIView(context: Context) -> ARView {
        // Create an ARView that does **not** start an AR session (cameraMode .nonAR).
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        //        arView.scene.synchronizationService
//        print(arView.scene.synchronizationService as Any)
        print("scene: \(arView.scene)")
        
        
        let anchor = AnchorEntity(world: .zero) // Add the airplane model to the scene.
        anchor.addChild(airplaneEntity)
        print("Airplane position (coordinates): \(airplaneEntity.position)")
        
        // Add a directional light to illuminate the airplane
        let light = DirectionalLight()
        light.light.intensity = 4000  // Adjust intensity as needed
        light.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(1, 1, 1), relativeTo: nil)  // Position and orient the light
        anchor.addChild(light)
        print("Light position (coordinates): \(light.position)")
        
        let light2 = DirectionalLight()
        light2.light.intensity = 4000  // Adjust intensity as needed
        light2.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(-1, 1, -1), relativeTo: nil)  // Position and orient the second light differently
        anchor.addChild(light2)
        
        // Optionally, if you want to print its coordinates too, add to the subscribe block:
        print("Light2 position (coordinates): \(light2.position)\n")
        
        arView.scene.addAnchor(anchor)
        // Subscribe to per‑frame updates and apply the latest orientation from the view model.
        arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            airplaneEntity.transform.rotation = viewModel.orientation
        }.store(in: &context.coordinator.cancellables)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // No dynamic UI updates are needed – everything runs via the per‑frame subscription.
    }
    
    class Coordinator {
        var cancellables = Set<AnyCancellable>()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
