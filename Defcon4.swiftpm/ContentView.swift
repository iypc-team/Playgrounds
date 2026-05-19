// Defcon4 05/19/2026-3
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/Defcon4.swiftpm
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            SceneKitView(scene: viewModel.scene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
            
            VStack {
                Spacer()
                Button(action: {
                    if viewModel.isFighterRotating {
                        viewModel.stopFighterRotation()
                    } else {
                        viewModel.startFighterRotation()
                    }
                }) {
                    Text(viewModel.isFighterRotating ? "Disable Motion Control" : "Enable Motion Control")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.startFighterRotation()
        }
        .onDisappear {
//            viewModel.stopFighterRotation()
        }
    }
}

#Preview {
    ContentView()
}
