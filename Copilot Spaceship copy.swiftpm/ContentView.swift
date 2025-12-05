// Copilot Spaceship copy 12/04/2025-3
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm
// 

import SwiftUI

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        VStack {
            if let entity = model.entity {
                RealityKitView(entity: entity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        Button("Rotate", action: {
                            model.rotateModel()
                        })
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.green)
                        , alignment: .bottom // Adjust alignment as needed
                    )
            } else {
                Text("Loading model...")
                    .onAppear {
                        model.loadModel()
                    }
            }
        }
    }
}
