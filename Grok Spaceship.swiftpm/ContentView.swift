// Grok Spaceship  11/22/2025-2
// SwiftUI + RealityKit, MVVM, iOS 16, loadModel(Airplane.usdz), lighting, gesture, recognizers, 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RealityKitViewModel()
    var body: some View {
        RealityKitView(modelName: "YourModel.usdz", rotation: $viewModel.rotation)
            .frame(width: 500, height: 500)
    }
}


