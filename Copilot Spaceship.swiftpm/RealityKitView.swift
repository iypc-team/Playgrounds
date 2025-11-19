// 
// 

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    var entity: Entity?
    
    func makeUIView(context: Context) -> RKView {
        let rkView = RKView()
        if let model = entity {
            rkView.scene.addAnchor(AnchorEntity(world: .zero))
            rkView.scene.anchors[0].addChild(model)
        }
        return rkView
    }
    
    func updateUIView(_ uiView: RKView, context: Context) {
        // Update logic if needed
    }
}

