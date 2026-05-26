//  FrameworkHelper 05/26/2026-3
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/FrameworkHelper.swiftpm
//  Project:  FrameworkHelper.swiftpm
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    
    init(repository: FrameworksRepository = StaticFrameworksRepository()) {
        _viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(
                        error: error,
                        retryAction: {
                            // guard against concurrent loads from the view side too
                            guard !viewModel.isLoading else { return }
                            Task { await viewModel.load() }
                        }
                    )
                } else if viewModel.frameworks.isEmpty {
                    Text("No frameworks available")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("No frameworks available")
                } else {
                    List(viewModel.frameworks) { framework in
                        NavigationLink(value: framework) {
                            FrameworkRow(framework: framework)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Frameworks:")
            .navigationDestination(for: Framework.self) { framework in
                MethodListView(framework: framework)
            }
            .task {
                // Only trigger initial load if nothing is loaded and not already loading
                if viewModel.frameworks.isEmpty && !viewModel.isLoading {
                    await viewModel.load()
                }
            }
            .refreshable {
                // Let the view model handle concurrency, but avoid firing when already loading
                if !viewModel.isLoading {
                    await viewModel.load()
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView()
}
