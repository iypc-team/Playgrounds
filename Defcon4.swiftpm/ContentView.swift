// Defcon4 05/23/2026-3
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/Defcon4.swiftpm

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            // Single SceneKitView — universe background is now a node inside this scene
            SceneKitView(scene: viewModel.scene)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // UI Overlay
            VStack {
                Spacer()
                
                Button(action: {
                    if viewModel.isFighterRotating {
                        viewModel.stopFighterRotation()
                    } else {
                        viewModel.startFighterRotation()
                    }
                }) {
                    Text(viewModel.isFighterRotating ? "Stop Motion" : "Start Motion")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.isFighterRotating
                            ? Color.red.opacity(0.9)
                            : Color.blue.opacity(0.9)
                        )
                        .cornerRadius(12)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    ContentView()
}
