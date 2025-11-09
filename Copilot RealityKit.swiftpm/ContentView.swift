// Copilot RealityKit  11/09/2025-1
// RealityKit  with model Airplane.usdz MVVM paradigm
// RealityKit model Airplane.usdz MVVM

import SwiftUI

struct ContentView: View {
    // Inject ViewModel
    private let viewModel = AirplaneViewModel()
    
    var body: some View {
        RealityView(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
    }
}

// 
