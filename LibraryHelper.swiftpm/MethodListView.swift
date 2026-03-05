// MethodListView.swift
//
// Updated to display methods, properties, constants, and functions in separate
// sections. The view only triggers fetch if the view model hasn't already loaded data.

import SwiftUI

struct MethodListView: View {
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
    }
    
    var body: some View {
        List {
            if !viewModel.methods.isEmpty {
                Section(header: Text("Methods")) {
                    ForEach(viewModel.methods, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            if !viewModel.properties.isEmpty {
                Section(header: Text("Properties")) {
                    ForEach(viewModel.properties, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            if !viewModel.constants.isEmpty {
                Section(header: Text("Constants")) {
                    ForEach(viewModel.constants, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            if !viewModel.functions.isEmpty {
                Section(header: Text("Functions")) {
                    ForEach(viewModel.functions, id: \.self) { item in
                        Text(item)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.fetchMethods()
        }
        .navigationTitle(viewModel.framework.name)
        .task {
            // Only fetch if the view model hasn't already populated data.
            // This avoids duplication when MethodViewModel triggers a fetch in its init.
            if viewModel.methods.isEmpty {
                await viewModel.fetchMethods()
            }
        }
    }
}
