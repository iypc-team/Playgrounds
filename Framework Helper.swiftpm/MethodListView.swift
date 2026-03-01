// MethodListView.swift
//
// Updated to avoid duplicate fetches: the view only triggers fetch if the view model
// hasn't already loaded methods. Removed dead/commented-out code.

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
                .padding(.top)
            
            List(viewModel.methods, id: \.self) { method in
                Text(method)
            }
            .refreshable {
                await viewModel.fetchMethods()
            }
        }
        .navigationTitle(viewModel.framework.name)
        .task {
            // Only fetch if the view model hasn't already populated methods.
            // This avoids duplication when MethodViewModel triggers a fetch in its init.
            if viewModel.methods.isEmpty {
                await viewModel.fetchMethods()
            }
        }
    }
}
