// Copilot Spaceship  12/03/2025-4
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        VStack {
            if let entity = model.entity {
                RealityKitView(entity: entity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Loading model...")
                    .onAppear {
                        model.loadModel()
                    }
            }
        }
    }
}
