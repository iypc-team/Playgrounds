// MethodListView.swift
// 

import SwiftUI

struct MethodListView: View {
    let framework: Framework
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        self.framework = framework
        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(error: errorMessage) {
                    Task { await viewModel.fetchMethods() }
                }
            } else {
                List {
                    makeSection(title: "Methods", items: viewModel.methods)
                    makeSection(title: "Properties", items: viewModel.properties)
                    makeSection(title: "Constants", items: viewModel.constants)
                    makeSection(title: "Functions", items: viewModel.functions)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(framework.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMethods()
        }
        .onDisappear {
            viewModel.cancelFetch()
        }
    }
    
    private func makeSection(title: String, items: [String]) -> some View {
        Section {
            if items.isEmpty {
                Text("No \(title.lowercased()) available")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
            }
        } header: {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MethodListView(framework: Framework(name: "SwiftUI"))
    }
}
