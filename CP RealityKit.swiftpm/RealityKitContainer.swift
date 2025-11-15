// 
// 

import SwiftUI
import RealityKit

struct RealityKitContainer: UIViewRepresentable {
    let entities: [Entity?]
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero)
        arView.setup(entities: entities.compactMap { $0 })
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        uiView.updateEntities(entities: entities.compactMap { $0 })
    }
}

class CustomARView: ARView {
    private var rootAnchor = AnchorEntity(world: .zero)
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.scene.addAnchor(rootAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(entities: [Entity]) {
        // Add initial entities
        for entity in entities {
            rootAnchor.addChild(entity)
        }
    }
    
    func updateEntities(entities: [Entity]) {
        // Clear and reload current entities
        rootAnchor.children.removeAll()
        for entity in entities {
            rootAnchor.addChild(entity)
        }
    }
}

