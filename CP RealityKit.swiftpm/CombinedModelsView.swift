// 
// 

import SwiftUI
import RealityKit

struct CombinedModelsView: View {
    @StateObject var viewModel = CombinedModelsViewModel()
    
    var body: some View {
        VStack {
            RealityKitContainer(entities: [viewModel.airplaneEntity, viewModel.spaceshipEntity])
            
            HStack {
                Button("Load Airplane") {
                    viewModel.loadAirplane()
                }
                .padding()
                .background(Color.green)
                
                Button("Load Spaceship") {
                    viewModel.loadSpaceship()
                }
                .padding()
                .background(Color.blue)
                
                Button("Load Both") {
                    viewModel.loadBothModels()
                }
                .padding()
                .background(Color.yellow)
            }
        }
        .onAppear {
            viewModel.loadBothModels() // Load both models on view appearance
        }
    }
}

