// GPT RealityKit  06/01/2026-1
// ContentViewReality.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT%20RealityKit.swiftpm
// 

import SwiftUI

struct ContentViewReality: View {
    @StateObject private var vm = RealityViewModel()
    
    var body: some View {
        VStack {
            RealityKitView(vm: vm)
                .ignoresSafeArea()
            
            Slider(value: Binding(
                get: { Double(vm.scale) },
                set: { newVal in
                    vm.scaleModel(to: Float(newVal))
                }
            ), in: 1.0...4.0)
            .padding()
        }
        .onAppear { vm.loadModel(named: "Airplane.usdz") }
    }
}
