//  RealityKit Scene  01/30/2026-2
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/RealityKit%20Scene.swiftpm
//  
//  

import SwiftUI

struct ContentView: View {
    @State private var rotationSpeed: Float = 0.0
    
    private let speeds: [Float] = [0.15, 0.3, 0.6]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            RealityKitView(rotationSpeed: $rotationSpeed)
                .ignoresSafeArea()
            
            HStack(spacing: 16) {
                Button("Toggle Rotation") {
                    toggleSpeed()
                }
                .background(.ultraThinMaterial)
                Spacer()
                Button("Stop Rotation") {
                    stopRotation()
                }
                .background(.ultraThinMaterial)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            
            .cornerRadius(12)
            .padding(.bottom, 32)
        }
    }
    
    private func toggleSpeed() {
        guard let index = speeds.firstIndex(of: rotationSpeed) else {
            rotationSpeed = speeds[0]
            return
        }
        rotationSpeed = speeds[(index + 1) % speeds.count]
    }
    
    private func stopRotation() {
        rotationSpeed = 0.0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
