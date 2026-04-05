// DF2-Enemy  04/05/2026-2
// ContentView.swift
// Project: DF2-Enemy.swiftpm
// Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2-Enemy.swiftpm
// 

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var viewModel = EnemySceneViewModel()
    
    let scenes = ["fighter.scn", "fighterPBR.scn", "newFighter_2.scn", "ship.scn", "smooth_ship.scn"]
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
                .foregroundColor(Color.black)
                .background(Color.white.opacity(1.0))
                .cornerRadius(8)
                .padding()
                
                // Fixed: Assign the non-optional array and check if not empty (no conditional binding on the array)
                if let utility = viewModel.utility {
                    let materials = utility.getMaterials()  // Assign the array (non-optional)
                    if !materials.isEmpty {  // Check if it has content
                        VStack(alignment: .leading) {
                            Text("Materials (\(materials.count)):")
                                .font(.headline)
                                .padding(.top)
                            ForEach(materials.indices, id: \.self) { index in
                                Text(materials[index].name ?? "Unnamed Material \(index + 1)")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                    } else {
                        Text("No materials found in scene.")
                            .padding()
                    }
                } else {
                    Text("Materials not available (scene not loaded).")
                        .padding()
                }
                
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
