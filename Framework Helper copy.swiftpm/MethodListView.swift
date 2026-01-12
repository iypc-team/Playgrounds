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
            // Remove debug prints or gate them behind a debug flag
            // print("struct MethodListView: View")
            // print(".onAppear")
        }
    }
}

