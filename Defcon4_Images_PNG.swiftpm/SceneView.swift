// Updated SceneView.swift
// found

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
            
            if isRotatingX || isRotatingY || isRotatingZ {
                Task {
                    do {
                        try await viewModel.captureAndSavePNG(scnView: scnView, axis: isRotatingX ? "X" : isRotatingY ? "Y" : "Z", rotation: isRotatingX ? rotationX : isRotatingY ? rotationY : rotationZ)
                    } catch {
                        // Handle error, e.g., log or alert (propagate to View if needed)
                        print("Error saving PNG: \(error)")
                    }
                }
            }
        }
    }
    
    private func findNodeWithGeometry(in node: SCNNode?) -> SCNNode? {
        guard let node = node else { return nil }
        if node.geometry != nil {
//            print("")
//            print("node: \(node) ")
            return node
        }
        for child in node.childNodes {
            if let childNodes = findNodeWithGeometry(in: child) {
//                print("")
//                print("childNodes: \(childNodes) ")
                return childNodes
            }
        }
        return nil
    }
    
}
