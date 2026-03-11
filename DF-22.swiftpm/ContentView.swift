//  DF-22  03/11/2026-2
//  ContentView.swift
//  Project:  DF-22.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF-2.swiftpm
//  

import SwiftUI
import SceneKit

struct ContentView: UIViewRepresentable {
    @StateObject private var viewModel = SceneViewModel()
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = viewModel.scene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = viewModel.scene
        // Configure the view
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.darkGray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
