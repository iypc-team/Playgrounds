// Grok Spaceship  11/24/2025-1
// SwiftUI + RealityKit, MVVM, iOS 16, loadModel(Airplane.usdz), lighting, gesture, recognizers, 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RealityKitViewModel()
    
    var body: some View {
        VStack {
            RealityKitView(modelName: "Spaceship.usdz", rotation: $viewModel.rotation)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        HStack {
            Button(action: { print("Rotate pressed" )}, label: {
                Text("Rotate")
            })
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
        }
    }
}

