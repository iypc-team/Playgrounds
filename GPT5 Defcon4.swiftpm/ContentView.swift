//  GPT5 Defcon4 copy 10/27/2025-1
//  GPT5-mini
//  

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        VStack {
            SceneView(viewModel: viewModel)
                .frame(height: .infinity)
            
//            Button("Change Color") {
//                if let node = viewModel.selectedNode {
//                    viewModel.updateNodeColor(node: node, color: .blue)
//                }
//            }
        }
        HStack {
            Button("Change Color") {
                if let node = viewModel.selectedNode {
                    viewModel.updateNodeColor(node: node, color: .blue)
                }
//                    .background(UIColor(.black))
//                    .foregroundColor(UIColor(.white))
            }
        }
    }
}

//
