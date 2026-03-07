//  Inspect_SCN 03/07/2026-3
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/Defcon4%20copy.swiftpm
//  
//  

import SwiftUI
import SceneKit
import os  // Add this import for logging

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    // Initialize a logger for this view
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Defcon4", category: "ContentView")
    
    // File names from Resources directory
    private let resourceFiles = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighterPBR.scn",
        "newFighter.scn",
        "new_enemy.scn",
        "smooth_ship.scn"
    ]
    
    // State for selected file
    @State private var selectedFile = "fighter.scn"
    
    var body: some View {
        SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("3D Fighter Scene")
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
