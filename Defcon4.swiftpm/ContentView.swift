// Defcon4 02/03/2026-1
// ContentView.swift
// Repository: https://github.com/iypc-team/Playgrounds/blob/main/Defcon4.swiftpm/ContentView.swift

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    //  Initializer for conditional binding must have Optional type, not 'SCNScene'
    var body: some View {
        SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("3D Fighter Scene")
    }
}

#Preview {
    ContentView()
}
