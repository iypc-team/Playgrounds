//  Framework Helper  03/04/2026-1
//  ContentView.swift
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
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
                        isLoading: viewModel.isLoading,
                        retryAction: {
                            // guard against concurrent loads from the view side too
                            guard !viewModel.isLoading else { return }
                            Task { await viewModel.load() }
                        }
                    )
                } else if viewModel.frameworks.isEmpty {
                    Text("No libraries available")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("No libraries available")
                } else {
                    List(viewModel.frameworks) { framework in
                        NavigationLink(value: framework) {
                            FrameworkRow(framework: framework)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Libraries")
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

// MARK: - Small helper subviews for clarity & accessibility
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
