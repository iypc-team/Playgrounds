// Grok Spaceship  11/24/2025-3
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
            Button(action: {
                print("Rotate pressed" )
            }, label: {
                Text("Rotate")
            })
            .foregroundColor(.black)
            .background(Color.green)
            .font(.largeTitle)
            .padding(20)
        }
        
    }
}

