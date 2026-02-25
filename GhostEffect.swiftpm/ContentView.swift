//  GhostEffect  02/25/2026-1
//  ContentView.swift
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/GhostEffect.swiftpm
//  

import SwiftUI
import SceneKit
import UIKit

struct ContentView: UIViewRepresentable {
    @ObservedObject var viewModel: GhostSceneViewModel
    
    init(viewModel: GhostSceneViewModel = GhostSceneViewModel()) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = viewModel.scene
        scnView.pointOfView = viewModel.cameraNode
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Keep view synchronized with the view model
        if scnView.scene !== viewModel.scene {
            scnView.scene = viewModel.scene
        }
        scnView.pointOfView = viewModel.cameraNode
        scnView.isPlaying = true
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
