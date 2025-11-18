// Copilot Spaceship  11/18/2025-2
// RealityKit Entity.load model Spaceship.usdz no arView MVVM paradigm iOS 16

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ModelViewModel()
    
    var body: some View {
        VStack {
            Button("Load Spaceship Model") {
                viewModel.loadModel()
            }
            if let entity = viewModel.entity {
//                Text("Entity.components\n\(entity.components)")
                Text("entity.isEnabled: \(entity.isEnabled)")
                Text("entity.isActive: \(entity.isActive)")
                Text("entity.isAnchored: \(entity.isAnchored)")
                Text("entity.isEnabledInHierarchy: \(entity.isEnabledInHierarchy)")
//                Text("entity.isActive: \(entity.isActive)")
//                Text("entity.isActive: \(entity.isActive)")
                
                // Add logic for what you want to do with the loaded entity
            }
        }
    }
}
