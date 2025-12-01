//
// Type 'ARViewContainer' does not conform to protocol 'UIViewRepresentable'

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
    /// Closure called on every render pass – supplies the latest quaternion.
    let perFrameUpdate: (simd_quatf) -> Void
    
    func makeUIView(context: Context) -> ARView {
        // Create an ARView that does **not** start an AR session (cameraMode .nonAR).
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        print(arView)
        
        let anchor = AnchorEntity(world: .zero) // Add the airplane model to the scene.
        anchor.addChild(airplaneEntity)
        arView.scene.addAnchor(anchor)
        // Subscribe to per‑frame updates and forward the latest quaternion.
        arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            perFrameUpdate(context.coordinator.currentOrientation)
        }.store(in: &context.coordinator.cancellables)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // No dynamic UI updates are needed – everything runs via the per‑frame subscription.
    }
    
    class Coordinator {
        var cancellables = Set<AnyCancellable>()
        // Start with a neutral orientation (identity quaternion).
        var currentOrientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
