// Copilot Spaceship copy 12/07/2025-1
//  https://github.com/iypc-team/Playgrounds/tree/main/Copilot%20Spaceship%20copy.swiftpm 
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI

struct printInfo {
    init() {
        print("ContentView()")
    }
}

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    let pi = printInfo() 
    
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
                            print("\nRotate pressed")
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
