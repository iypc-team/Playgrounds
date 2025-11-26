// Grok Spaceship  11/25/2025-3
// SwiftUI + RealityKit, MVVM, iOS 16, loadModel(Airplane.usdz), lighting, gesture, recognizers, 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RealityKitViewModel()
    
    var body: some View {
        VStack {
            RealityKitView(modelName: "Airplane.usdz")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        HStack {
            Button(action: {
                print("\nRotate pressed" )
                viewModel.rotate()
            }, label: {
                Text("Rotate")
            })
            .foregroundColor(.white)
            .background(Color.green)
            .font(.largeTitle)
            .padding(20)
        }
        
    }
}

