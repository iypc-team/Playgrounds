//  Inspect_SCN 03/07/2026-7
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm
//  

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    // File names from Resources directory
    private let resourceFiles = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighterPBR.scn",
        "newFighter.scn",
        "new_enemy.scn",
        "smooth_ship.scn"
    ]
    
    // State for selected file, initialized to match SceneModel's default sceneName
    @State private var selectedFile = "newFighter.scn"
    
    var body: some View {
        SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("3D Fighter Scene")
            .onChange(of: selectedFile) { newValue in
                viewModel.loadScene(for: newValue)
                
            }
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(resourceFiles, id: \.self) { file in
                                Button(file) {
                                    selectedFile = file
                                }
                            }
                        } label: {
                            Text("Select File: \(selectedFile)")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(8)
                        }
                        .tint(.white)
                        Spacer()
                    }
                    Spacer()
                }
                    .padding()
            )
    }
}

#Preview {
    ContentView()
}
