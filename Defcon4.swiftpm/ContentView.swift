//  Defcon4 02/02/2026-2
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/Defcon4.swiftpm
//  
//  

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("3D Fighter Scene")
            .onAppear {
                
            }
            .onDisappear {
                
            }
    }
}

#Preview {
    ContentView()
}
