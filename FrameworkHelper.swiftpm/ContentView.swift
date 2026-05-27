//  FrameworkHelper 05/27/2026-1
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/FrameworkHelper.swiftpm
//  

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: ContentViewModel())
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.frameworks) { framework in
                NavigationLink(value: framework) {
                    FrameworkRow(framework: framework)
                }
            }
            .navigationTitle("Apple Frameworks")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Framework.self) { framework in
                MethodListView(framework: framework)
            }
            .refreshable {
                await viewModel.loadFrameworks()
            }
            .task {
                await viewModel.loadFrameworks()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading frameworks...")
                        .progressViewStyle(.circular)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
