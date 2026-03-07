//  Defcon4 copy 03/07/2026-1
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
    
    var body: some View {
        SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("3D Fighter Scene")
    }
}

#Preview {
    ContentView()
}
