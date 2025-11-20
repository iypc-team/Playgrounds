// GPT RealityKit  11/10/2025-3
// RealityKit model Spaceship.usdz MVVM with gesture support
// iOS 16 RealityKit model Spaceship.usdz I do not require ARView. MVVM paradigm

// ContentViewReality.swift
import SwiftUI

struct ContentViewReality: View {
    @StateObject private var vm = RealityViewModel()
    @State private var scale: Float = 1.0
    
    var body: some View {
        VStack {
            RealityKitView(vm: vm)
                .edgesIgnoringSafeArea(.all)
            
            Slider(value: Binding(
                get: { Double(scale) },
                set: { newVal in
                    scale = Float(newVal)
                    vm.scaleModel(to: scale)
                }
            ), in: 1.0...4.0)
            .padding()
        }
        .onAppear { vm.loadModel(named: "Spaceship.usdz") }
    }
}
