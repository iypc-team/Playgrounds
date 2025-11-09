// GPT RealityKit  11/09/2025-1
// RealityKit model Airplane.usdz MVVM

import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject private var vm = AirplaneViewModel()
    
    var body: some View {
        VStack {
            if let entity = vm.modelEntity {
                Text("Model loaded: \(entity.name)")
                // You could embed a SceneKit or custom view to actually render it,
                // but since no ARView is required, maybe just show a message or use a
                // 3D-preview library.
            } else if let error = vm.error {
                Text("Error loading model: \(error.localizedDescription)")
            } else {
                ProgressView("Loading model…")
            }
        }
        .onAppear {
            vm.load()
        }
    }
}
