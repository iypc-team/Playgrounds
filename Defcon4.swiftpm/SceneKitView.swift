// SceneKitView.swift
// 

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.backgroundColor = .black
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false  // We control lighting ourselves
        scnView.antialiasingMode = .multisampling4X
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No-op – everything is managed in ViewModel
    }
}
