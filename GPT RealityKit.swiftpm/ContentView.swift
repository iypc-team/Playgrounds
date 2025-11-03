//  GPT RealityKit 11/03/2025 initial commit
//  

import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject private var viewModel = CubeViewModel()
    
    var body: some View {
        ZStack {
            RealityView { content in
                content.add(viewModel.anchor)
            }
            VStack {
                Spacer()
                Button("Randomize Cube") {
                    viewModel.randomizeCube()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
