// MethodListView.swift
//
// Displays methods, properties, constants, and functions for a selected framework.
// Uses MethodViewModel to load and display categorized lists.
// Section headers are colored blue for consistency.

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
            } else if let error = viewModel.errorMessage {
                ErrorView(
                    error: error,
                    isLoading: viewModel.isLoading,
                    retryAction: {
                        guard !viewModel.isLoading else { return }
                        Task { await viewModel.fetchMethods() }
                    }
                )
            } else {
                List {
                    Section(header: Text("Methods").font(.title).foregroundColor(.blue)) {
                        ForEach(viewModel.methods, id: \.self) { method in
                            Text(method)
                        }
                    }
                    if !viewModel.properties.isEmpty {
                        Section(header: Text("Properties").font(.title).foregroundColor(.blue)) {
                            ForEach(viewModel.properties, id: \.self) { property in
                                Text(property)
                            }
                        }
                    }
                    if !viewModel.constants.isEmpty {
                        Section(header: Text("Constants").font(.title).foregroundColor(.blue)) {
                            ForEach(viewModel.constants, id: \.self) { constant in
                                Text(constant)
                            }
                        }
                    }
                    if !viewModel.functions.isEmpty {
                        Section(header: Text("Functions").font(.title).foregroundColor(.blue)) {
                            ForEach(viewModel.functions, id: \.self) { function in
                                Text(function)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(framework.name)
        .task {
            if viewModel.methods.isEmpty && !viewModel.isLoading {
                await viewModel.fetchMethods()
            }
        }
        .refreshable {
            if !viewModel.isLoading {
                await viewModel.fetchMethods()
            }
        }
    }
}

// MARK: - Helper Subviews (reused from ContentView for consistency)
private struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.automatic)
                .accessibilityLabel("Loading")
                .accessibilityHint("Content is loading")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorView: View {
    let error: String
    let isLoading: Bool
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            .accessibilityLabel("Retry")
            .accessibilityHint(isLoading ? "Retry is disabled while loading" : "Tap to retry loading")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
