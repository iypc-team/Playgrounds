// Grok Spaceship  11/23/2025-1
// SwiftUI + RealityKit, MVVM, iOS 16, loadModel(Airplane.usdz), lighting, gesture, recognizers, 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RealityKitViewModel()
    
    var body: some View {
        RealityKitView(modelName: "Spaceship.usdz", rotation: $viewModel.rotation)
//            .frame(width: 500, height: 500)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Use all available space
    }
}


