// Defcon4 02/08/2026-1
// ContentView.swift
// Repository: https://github.com/iypc-team/Playgrounds/blob/main/Defcon4.swiftpm

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
            
            // Button overlay for controlling fighter (node) rotation
            VStack {
                Spacer()
                Button(action: {
                    if viewModel.isFighterRotating {
                        viewModel.stopFighterRotation()
                    } else {
                        viewModel.startFighterRotation()
                    }
                }) {
                    Text(viewModel.isFighterRotating ? "Stop Rotation" : "Start Rotation")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.bottom, 50)  // Adjust padding as needed
            }
        }
    }
}

#Preview {
    ContentView()
}
