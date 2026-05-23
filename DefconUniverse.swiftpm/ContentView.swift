// DefconUniverse  05/23/2026-2
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/DefconUniverse.swiftpm
// 

import SwiftUI

struct ContentView: View {
    @State private var isPaused: Bool = false
    
    var body: some View {
        ZStack {
            UniverseSceneView(isPaused: $isPaused)
                .ignoresSafeArea()
                .onDisappear {
                    // Stop all motion updates when the view leaves the screen
                    isPaused = true
                }
            
            // ── Pause Button Overlay ───────────────────────────────
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        isPaused.toggle()
                    } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
