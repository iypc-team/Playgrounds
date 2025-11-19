// GPT Spaceship  11/18/2025- initial commit
// 

import SwiftUI
import RealityKit

struct SpaceshipView: View {
    @StateObject private var viewModel = SpaceshipViewModel()
    
    var body: some View {
        RealityViewRepresentable(entity: viewModel.modelEntity)
//            .onAppear { viewModel.loadModel() }
    }
}
