// Copilot Spaceship  11/21/2025-1
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        VStack {
            if let entity = model.entity {
                RealityKitView(entity: entity)
                    .frame(width: 500, height: 500)
            } else {
                Text("Loading model...")
                    .onAppear {
                        model.loadModel()
                    }
            }
        }
    }
}
