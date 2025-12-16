//  Defcon4 SwiftUI 12/16/2025-1
/*  
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4%20SwiftUI.swiftpm
 */

import SwiftUI
import SceneKit

// MARK: – iOS version (UIViewRepresentable)
struct SceneKitView: UIViewRepresentable {
    // You can pass in any data you need to configure the scene
    var scene: SCNScene?
    var allowsCameraControl: Bool = true
    var backgroundColor: UIColor = .black
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = allowsCameraControl
        scnView.backgroundColor = backgroundColor
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = context.coordinator   // optional, for per‑frame callbacks
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Assign the scene (or replace it) whenever the binding changes
        scnView.scene = scene
    }
    
    // Optional: coordinator for SCNSceneRendererDelegate callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        // Example: rotate a node each frame
        func renderer(_ renderer: SCNSceneRenderer,
                      updateAtTime time: TimeInterval) {
            // guard let node = renderer.scene?.rootNode.childNode(withName:"box", recursively:true) else { return }
            // node.eulerAngles.y = Float(time).truncatingRemainder(dividingBy: .pi * 2)
        }
    }
}

//
