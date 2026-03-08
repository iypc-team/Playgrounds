//  ScenekitView.swift
//
// 

import SwiftUI
import SceneKit

struct ScenekitView: UIViewRepresentable {
    @ObservedObject var viewModel: SceneViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        // Universe scene is set up independently but not assigned to the view
        _ = viewModel.setupUniverse()
        // Assign the independent enemy scene to the view
        scnView.scene = viewModel.setupEnemyScene()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Configure view properties
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.gray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        scnView.isTemporalAntialiasingEnabled = true
    }
}
