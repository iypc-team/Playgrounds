// DF2-Enemy  04/06/2026-3
// ContentView.swift
// Project: DF2-Enemy.swiftpm
// Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2-Enemy.swiftpm
// 

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var viewModel = EnemySceneViewModel()
    
    let scenes = UtilityFunctions.validScenes
    @State private var selectedScene = "smooth_ship.scn"
    
    var body: some View {
        ZStack {
            if viewModel.sceneFailed {
                Text("Scene '\(selectedScene)' failed to load. Please check resources.")
            } else {
                EnemySCNView(viewModel: viewModel, scene: viewModel.scene)
            }
            VStack {
                Picker("Select Scene", selection: $selectedScene) {
                    ForEach(scenes, id: \.self) { scene in
                        Text(scene).tag(scene)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .tint(Color.black)
                .background(Color.white.opacity(1.0))
                .cornerRadius(8)
                .padding()
                
                Spacer()
            }
        }
        .onChange(of: selectedScene) { newValue in
            viewModel.selectedScene = newValue
        }
    }
}

struct EnemySCNView: UIViewRepresentable {
    let viewModel: EnemySceneViewModel
    let scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        viewModel.configureView(scnView)
        scnView.scene = scene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
