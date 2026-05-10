//
// SceneKitView.swift
//

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    
    let scene: SCNScene
    
    let allowsCameraControl: Bool
    
    func makeUIView(context: Context) -> SCNView {
        
        let scnView = SCNView()
        
        scnView.scene = scene
        
        scnView.backgroundColor = .darkGray
        
        scnView.antialiasingMode = .multisampling4X
        
        scnView.autoenablesDefaultLighting = false
        
        scnView.isTemporalAntialiasingEnabled = true
        
        scnView.showsStatistics = true
        
        return scnView
    }
    
    func updateUIView(
        _ scnView: SCNView,
        context: Context
    ) {
        
        scnView.allowsCameraControl =
        allowsCameraControl
    }
}

