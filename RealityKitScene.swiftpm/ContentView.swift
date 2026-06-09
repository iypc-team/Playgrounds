// RealityKitScene  06/09/2026-1
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/RealityKitScene.swiftpm

import SwiftUI

struct ContentView: View {
    @State private var currentSpeed: RotationSpeed = .slow
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RealityKitView(rotationSpeed: $currentSpeed)
                .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 16) {
                    // Fix #2/#3: Label now reflects current speed via displayName.
                    Button {
                        toggleSpeed()
                    } label: {
                        Text("Speed: \(currentSpeed.displayName)")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        currentSpeed = .off
                    } label: {
                        Text("Stop")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    // Fix #4: Disabled when already stopped so both buttons
                    // have distinct, unambiguous roles.
                    .disabled(currentSpeed == .off)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .preferredColorScheme(.dark)
    }
    
    // Fix #4: .off excluded from toggle cycle — "Toggle Speed" and "Stop"
    // now each have one clear purpose.
    // Cycle: slow → medium → fast → slow → …
    // If called while stopped, restarts at .slow.
    private func toggleSpeed() {
        let activeSpeeds = RotationSpeed.allCases.filter { $0 != .off }
        guard let idx = activeSpeeds.firstIndex(of: currentSpeed) else {
            currentSpeed = .slow
            return
        }
        currentSpeed = activeSpeeds[(idx + 1) % activeSpeeds.count]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
