// Grok Spaceship  11/21/2025-2
// SwiftUI + RealityKit, MVVM, iOS 16, loadModel(Airplane.usdz), lighting, gesture, recognizers, 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AirplaneViewModel()
    
    var body: some View {
        AirplaneARView(viewModel: viewModel)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        viewModel.updateTransform(with: gesture)
                    }
            )
            .edgesIgnoringSafeArea(.all)
    }
}
