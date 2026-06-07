// RealityKitScene  06/07/2026-2
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
                    Button {
                        toggleSpeed()
                    } label: {
                        Text("Toggle Speed")
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
    
    private func toggleSpeed() {
        let allSpeeds = RotationSpeed.allCases
        guard let currentIndex = allSpeeds.firstIndex(of: currentSpeed) else {
            currentSpeed = .slow
            return
        }
        let nextIndex = (currentIndex + 1) % allSpeeds.count
        currentSpeed = allSpeeds[nextIndex]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
