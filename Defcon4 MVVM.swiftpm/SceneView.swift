// Updated SceneView.swift
// 

import SwiftUI
import SceneKit
import UIKit

struct SceneView: UIViewRepresentable {
    var scene: SCNScene?
    @Binding var rotationX: Float
    @Binding var rotationY: Float
    @Binding var rotationZ: Float
    @Binding var isRotatingX: Bool
    @Binding var isRotatingY: Bool
    @Binding var isRotatingZ: Bool
    
    // Add viewModel property to access SceneViewModel methods
    var viewModel: SceneViewModel
    
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
            scnView.setNeedsDisplay()
            
            // Capture and save PNG if rotating on a specific axis
            if isRotatingX {
                captureAndSavePNG(scnView: scnView, axis: "X", rotation: rotationX)
            } else if isRotatingY {
                captureAndSavePNG(scnView: scnView, axis: "Y", rotation: rotationY)
            } else if isRotatingZ {
                captureAndSavePNG(scnView: scnView, axis: "Z", rotation: rotationZ)
            }
        }
    }
    
    private func captureAndSavePNG(scnView: SCNView, axis: String, rotation: Float) {
        let snapshot = scnView.snapshot()
        let filename = "rotation\(axis)_\(Int(rotation)).png"
        // Use viewModel to resize and save the PNG
//        viewModel.resizeAndSavePNG(image: snapshot, filename: filename)
        // Value of type 'SceneViewModel' has no member 'resizeAndSavePNG'
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
