// CP RealityKit  11/15/2025-1
// 

import SwiftUI

struct CombinedModelsView: View {
    @StateObject var viewModel = CombinedModelsViewModel()
    
    var body: some View {
        VStack {
            RealityKitContainer(entities: [viewModel.airplaneEntity, viewModel.spaceshipEntity])
                .edgesIgnoringSafeArea(.all)
                .frame(height: 400)
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.loadAirplane()
                }) {
                    Text("Load Airplane")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    viewModel.loadSpaceship()
                }) {
                    Text("Load Spaceship")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    viewModel.loadBothModels()
                }) {
                    Text("Load Both")
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadBothModels() // Auto-load models on appearance
        }
    }
}

