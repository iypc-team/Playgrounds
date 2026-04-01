// DF2-Enemy  04/01/2026-2
// ContentView.swift
// Project: DF2-Enemy.swiftpm
// Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2-Enemy.swiftpm
// Refactored to MVVM: View delegates logic to ViewModel.
// 

import SwiftUI
import SceneKit

struct ContentView: UIViewRepresentable {
    @StateObject private var viewModel = EnemySceneViewModel()
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        viewModel.setupScene()
        viewModel.configureView(scnView)
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // No additional updates needed; configuration is handled in makeUIView.
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
