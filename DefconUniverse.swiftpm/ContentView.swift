// DefconUniverse  05/21/2026-1
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/blob/main/DefconUniverse.swiftpm

import SwiftUI

struct ContentView: View {
    @State private var isRotating: Bool = false
    
    var body: some View {
        SceneKitView(isRotating: $isRotating)
        // Argument passed to call that takes no arguments.
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
