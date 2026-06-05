// ARViewContainer.swift
// 

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let usdzURL: URL
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        loadModel(into: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadModel(into arView: ARView) {
        Task { @MainActor in
            do {
                // ✅ Fixed: Entity.load(contentsOf:) is the correct static
                //    synchronous API — Entity(contentsOf:) does not exist here.
                let entity = try Entity.load(contentsOf: usdzURL)
                
                let bounds = entity.visualBounds(relativeTo: nil)
                let maxExtent = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
                let scale = maxExtent > 0 ? 1.5 / maxExtent : 1.0
                
                entity.scale = .init(repeating: scale)
                
                let anchor = AnchorEntity(world: .zero)
                anchor.addChild(entity)
                arView.scene.addAnchor(anchor)
            } catch {
                print("USDZ load failed: \(error.localizedDescription)")
            }
        }
    }
}
