// 
// 

import SwiftUI
import SceneKit

// SCNView as a SwiftUI View
struct SceneView: UIViewRepresentable {
    var scene: SCNScene?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.black
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
    }
}
