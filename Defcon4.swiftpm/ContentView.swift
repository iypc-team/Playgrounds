// Defcon4 02/02/2026-3
// ContentView.swift
// Created: 2026-02-02
// Repository: https://github.com/iypc-team/Playgrounds/blob/main/Defcon4.swiftpm/ContentView.swift

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    //  Initializer for conditional binding must have Optional type, not 'SCNScene'
    var body: some View {
        if let scene = viewModel.scene {
            SceneKitView(scene: scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
        } else {
            Text("Loading 3D Fighter Scene...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
