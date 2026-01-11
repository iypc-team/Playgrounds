// 
// 

import SwiftUI

struct MethodListView: View {
    @ObservedObject var viewModel: MethodViewModel
    
    var body: some View {
        VStack {
            Text("Methods for \(viewModel.framework.name)")
                .font(.largeTitle)
                .padding()
            
            List(viewModel.methods, id: \.self) { method in
                Text(method)
            }
            .navigationTitle(viewModel.framework.name)
        }
        .onAppear {
            print("\(viewModel.framework.name)")
            print("framework.name.count: \(viewModel.framework.name.count)")
            print("framework.id: \(viewModel.framework.id)")
            print()
        }
    }
}
