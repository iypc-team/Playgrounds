// GPT RealityKit  11/09/2025-3
// RealityKit model Airplane.usdz MVVM

import SwiftUI
import SceneKit

struct AirplaneView: View {
    @StateObject private var vm = AirplaneViewModel()
    
    var body: some View {
        VStack {
            if let scene = vm.scene {
                SceneView(
                    scene: scene,
                    options: [.autoenablesDefaultLighting, .allowsCameraControl]
                )
                .frame(height: 400)
                .cornerRadius(12)
                .shadow(radius: 10)
                
            } else if let error = vm.error {
                Text("❌ Failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                ProgressView("Loading Airplane.usdz…")
            }
        }
        .padding()
        .onAppear {
            vm.load()
        }
    }
}

