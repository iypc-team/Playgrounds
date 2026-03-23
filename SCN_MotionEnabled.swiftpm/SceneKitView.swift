// SceneKitView.swift
// 

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    
    let scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        
        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = .black
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        view.showsStatistics = false
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
        if uiView.scene !== scene {
            uiView.scene = scene
        }
    }
}
