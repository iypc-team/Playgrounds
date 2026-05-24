// RealityKitView.swift
// 

import SwiftUI
import UIKit
import RealityKit
import ARKit

/// Use as a SwiftUI view wrapper. We will NOT run an AR session.
struct RealityKitView: UIViewRepresentable {
    @ObservedObject var vm: RealityViewModel
    
    final class Coordinator {
        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        var attachedModelID: ObjectIdentifier?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // Do not run an AR session — leave it stopped (default).
        // Alternatively, explicitly pause to ensure no tracking:
        arView.session.pause()
        
        arView.environment.background = .color(.init(white: 0.95, alpha: 1.0))
        arView.scene.addAnchor(context.coordinator.anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard let model = vm.modelEntity else { return }
        
        let modelID = ObjectIdentifier(model)
        
        if context.coordinator.attachedModelID != modelID {
            context.coordinator.anchor.children.removeAll()
            model.generateCollisionShapes(recursive: true) // optional
            context.coordinator.anchor.addChild(model)
            context.coordinator.attachedModelID = modelID
        }
        
        // Position / scale tweaks as needed:
        model.transform.scale = SIMD3<Float>(repeating: vm.scale)
        model.transform.translation = SIMD3<Float>(0, 0, 0)
    }
}
