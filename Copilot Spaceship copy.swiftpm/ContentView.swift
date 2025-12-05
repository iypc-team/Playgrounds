// Copilot Spaceship copy 12/05/2025-2
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI
struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        VStack {
            if let _ = model.entity {
                RealityKitView(model: model)  // Pass model, not entity
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                model.scale = Float(value)
                            }
                    )
                    .overlay(
                        Button("Rotate") {
                            Task {
                                await model.rotateModel()
                            }
                        }
                            .padding(10)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .background(Color.black)
                        , alignment: .bottom
                    )
            } else {
                Text("Loading model...")
                    .onAppear { model.loadModel() }
            }
        }
    }
}
