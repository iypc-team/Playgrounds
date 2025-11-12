// Copliot RealityKit  11/12/2025-1
// iOS 16 RealityKit model Airplane.usdz I do not require ARView. MVVM paradigm implementation skeleton
// 

import SwiftUI
import RealityKit

struct AirplaneView: View {
    @StateObject private var viewModel = AirplaneViewModel()
    
    var body: some View {
        VStack {
            if let modelEntity = viewModel.modelEntity {
                Model3DView(entity: modelEntity)                 // Display the 3D model
                    .frame(width: 300, height: 300)
                    .background(Color.gray.opacity(0.2))         // Background placeholder
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)                              // Error message display
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Loading Airplane...")             // Loading state
            }
        }
        .onAppear {
            viewModel.loadAirplaneModel()                       // Start loading the model
        }
    }
}

struct ContentView: View {
    var body: some View {
        AirplaneView()                                          // Parent view
    }
}

