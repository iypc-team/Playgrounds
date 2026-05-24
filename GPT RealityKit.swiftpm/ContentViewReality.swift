// GPT RealityKit  05/24/2026-1
// ContentViewReality.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT%20RealityKit.swiftpm
// 

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
        .onAppear { vm.loadModel(named: "Airplane.usdz") }
    }
}
