// DF2-Enemy  04/03/2026-2
// ContentView.swift
// Project: DF2-Enemy.swiftpm
// Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2-Enemy.swiftpm
// 

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var viewModel = EnemySceneViewModel()
    
    var body: some View {
        if viewModel.sceneFailed {
            Text("Scene failed to load. Please check resources.")
        } else {
            EnemySCNView(viewModel: viewModel)
        }
    }
}

struct EnemySCNView: UIViewRepresentable {
    let viewModel: EnemySceneViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
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
