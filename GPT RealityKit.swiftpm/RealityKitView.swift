// 
// 

// RealityKitView.swift
import SwiftUI
import UIKit
import RealityKit
import ARKit

/// Use as a SwiftUI view wrapper. We will NOT run an AR session.
struct RealityKitView: UIViewRepresentable {
    @ObservedObject var vm: RealityViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // Do not run an AR session — leave it stopped (default).
        // Alternatively, explicitly pause to ensure no tracking:
        arView.session.pause()
        
        arView.environment.background = .color(.init(white: 0.95, alpha: 1.0))
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Remove previous anchors
        uiView.scene.anchors.removeAll()
        
        guard let model = vm.modelEntity else { return }
        
        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        model.generateCollisionShapes(recursive: true) // optional
        anchor.addChild(model)
        uiView.scene.addAnchor(anchor)
        
        // Position / scale tweaks as needed:
        model.transform.scale = SIMD3<Float>(repeating: 0.5)
        model.transform.translation = SIMD3<Float>(0, 0, 0)
    }
}
