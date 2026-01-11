// 
// 
//  print

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
            print(".onAppear")
        }
    }
}
