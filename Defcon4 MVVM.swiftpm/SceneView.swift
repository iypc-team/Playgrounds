// Updated SceneView.swift

import SwiftUI
import SceneKit

// SCNView as a SwiftUI View
struct SceneView: UIViewRepresentable {
    var scene: SCNScene?
    @Binding var rotationX: Float
    @Binding var rotationY: Float
    @Binding var rotationZ: Float
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.black
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        if let node = findNodeWithGeometry(in: scnView.scene?.rootNode) {
            node.eulerAngles.x = rotationX * .pi / 180
            node.eulerAngles.y = rotationY * .pi / 180
            node.eulerAngles.z = rotationZ * .pi / 180
            scnView.setNeedsDisplay()  // Force redraw
        }
    }
    
    private func findNodeWithGeometry(in node: SCNNode?) -> SCNNode? {
        guard let node = node else { return nil }
        if node.geometry != nil {
            return node
        }
        for child in node.childNodes {
            if let found = findNodeWithGeometry(in: child) {
                return found
            }
        }
        return nil
    }
}
