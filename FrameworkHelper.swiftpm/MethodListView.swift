// MethodListView.swift
//
// Display Methods, Properties, Constants and Functions in distinct sections.

import SwiftUI

struct MethodListView: View {
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
    }
    
    var body: some View {
        List {
            Section(header: Text("Methods")) {
                if viewModel.methods.isEmpty {
                    Text("No methods available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.methods, id: \.self) { method in
                        Text(method)
                    }
                }
            }
            
            Section(header: Text("Properties")) {
                if viewModel.properties.isEmpty {
                    Text("No properties available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.properties, id: \.self) { property in
                        Text(property)
                    }
                }
            }
            
            Section(header: Text("Constants")) {
                if viewModel.constants.isEmpty {
                    Text("No constants available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.constants, id: \.self) { constant in
                        Text(constant)
                    }
                }
            }
            
            Section(header: Text("Functions")) {
                if viewModel.functions.isEmpty {
                    Text("No functions available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.functions, id: \.self) { fn in
                        Text(fn)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.framework.name)
        .refreshable {
            await viewModel.fetchMethods()
        }
        .task {
            // Only fetch if no category has content
            if viewModel.methods.isEmpty && viewModel.properties.isEmpty && viewModel.constants.isEmpty && viewModel.functions.isEmpty {
                await viewModel.fetchMethods()
            }
        }
    }
}
