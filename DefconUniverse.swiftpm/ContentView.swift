// DefconUniverse  05/21/2026-4
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/DefconUniverse.swiftpm

import SwiftUI

struct ContentView: View {
    // Start as true so the scene is already rotating and the button label is correct
    @State private var isRotating: Bool = true
    
    var body: some View {
        UniverseSceneView(isRotating: $isRotating)
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                Button {
                    isRotating.toggle()
                } label: {
                    Label(
                        isRotating ? "Pause Rotation" : "Resume Rotation",
                        systemImage: isRotating ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .foregroundStyle(.white)
                }
                .padding(.bottom, 40)
            }
    }
}

#Preview {
    ContentView()
}
