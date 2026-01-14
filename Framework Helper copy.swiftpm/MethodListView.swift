// 
// 
//  print

import SwiftUI

struct MethodListView: View {
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
    }
    
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
//            viewModel.fetchClassesAndFunctions(for: viewModel.framework.name)
            print("struct MethodListView: View")
        }
    }
}

