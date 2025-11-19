// 
// 

import SwiftUI
import ARKit
import RealityKit
import UIKit

struct RealityViewRepresentable: UIViewRepresentable {
    let entity: ModelEntity?
    
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        // Simple camera and lighting
        view.environment.background = .color(.black)
//        view.installGestures([.all], for: entity )
        
        if let entity = entity {
            let anchor = AnchorEntity(world: [0, 0, 0])
            anchor.addChild(entity)
            view.scene.addAnchor(anchor)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

