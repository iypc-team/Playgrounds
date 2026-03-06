// MethodListView.swift
//
// Refactored to remove repetition by extracting a reusable CategorySection view.

import SwiftUI

struct MethodListView: View {
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
    }
    
    var body: some View {
        List {
            CategorySection(title: "Methods",
                            items: viewModel.methods,
                            emptyMessage: "No methods available")
            
            CategorySection(title: "Properties",
                            items: viewModel.properties,
                            emptyMessage: "No properties available")
            
            CategorySection(title: "Constants",
                            items: viewModel.constants,
                            emptyMessage: "No constants available")
            
            CategorySection(title: "Functions",
                            items: viewModel.functions,
                            emptyMessage: "No functions available")
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.framework.name)
        .refreshable {
            await viewModel.fetchMethods()
        }
        .task {
            await fetchIfNeeded()
        }
    }
    
    private func fetchIfNeeded() async {
        if viewModel.methods.isEmpty &&
            viewModel.properties.isEmpty &&
            viewModel.constants.isEmpty &&
            viewModel.functions.isEmpty
        {
            await viewModel.fetchMethods()
        }
    }
    
    private struct CategorySection: View {
        let title: String
        let items: [String]
        let emptyMessage: String
        
        var body: some View {
            Section(header: Text(title)) {
                if items.isEmpty {
                    Text(emptyMessage)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                    }
                }
            }
        }
    }
}
