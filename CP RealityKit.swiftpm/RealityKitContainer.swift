// 
// 

import SwiftUI
import RealityKit

struct RealityKitContainer: UIViewRepresentable {
    let entities: [Entity?]
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let arView = CustomARView(frame: .zero)
        
        // Add all entities to a single anchor and attach to RealityKit scene
        let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: 0))
        
        for entity in entities.compactMap({ $0 }) { // Using compactMap to unwrap non-nil entities
            anchor.addChild(entity)
        }
        
        arView.scene.addAnchor(anchor)
        
        // Add ARView to the container view
        view.addSubview(arView)
        arView.frame = view.bounds
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Subclass for RealityKit's ARView
class CustomARView: ARView {
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

