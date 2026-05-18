// Defcon4 05/18/2026-4
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/Defcon4.swiftpm
// 'fighterNode' does not rotate when 'Start Fighter Rotation' is pressed.

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
                    Text(viewModel.isFighterRotating ? "Stop Fighter Rotation" : "Start Fighter Rotation")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    ContentView()
}
