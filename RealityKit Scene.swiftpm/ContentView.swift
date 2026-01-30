//  RealityKit Scene  01/30/2026-1
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/RealityKit%20Scene.swiftpm
//  
//  

import SwiftUI
//import RealityKit
//import Combine

struct ContentView: View {
    @State private var rotationSpeed: Float = 0.0
    
    private let speeds: [Float] = [0.0375, 0.075, 0.15, 0.3, 0.6]
//    private let speeds: [Float] = [0.075, 0.15, 0.25, 0.5, 1.0]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            RealityKitView(rotationSpeed: $rotationSpeed)
                .ignoresSafeArea()
            
            Button("Toggle Rotation") {
                toggleSpeed()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.bottom, 32)
        }
    }
    
    private func toggleSpeed() {
        guard let index = speeds.firstIndex(of: rotationSpeed) else {
            rotationSpeed = speeds[0]
            return
        }
        print("index: \(index ) rotationSpeed: \(rotationSpeed)")
        rotationSpeed = speeds[(index + 1) % speeds.count]
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
