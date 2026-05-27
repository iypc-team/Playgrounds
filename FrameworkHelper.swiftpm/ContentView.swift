//  FrameworkHelper 05/27/2026-2
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/FrameworkHelper.swiftpm

import SwiftUI

struct ContentView: View {
    
    // ✅ Switched to LibraryViewModel — activates previously dead code and adds search support.
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.filteredFrameworks) { framework in
                NavigationLink(value: framework) {
                    FrameworkRow(framework: framework)
                }
            }
            .navigationTitle("Apple Frameworks")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Framework.self) { framework in
                MethodListView(framework: framework)
            }
            // ✅ Live search wired to LibraryViewModel.applySearchFilter()
            .searchable(text: $viewModel.searchText, prompt: "Search frameworks")
            .onChange(of: viewModel.searchText) {
                viewModel.applySearchFilter()
            }
            .refreshable {
                await viewModel.loadFrameworks()
            }
            .task {
                await viewModel.loadFrameworks()
            }
            // ✅ LoadingView replaces inline ProgressView.
            // ✅ ErrorView replaces fragile .alert(isPresented: .constant(...)) pattern.
            //    ErrorView exposes a retry action so the user can recover without leaving the screen.
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error) {
                        viewModel.clearError()
                        Task { await viewModel.loadFrameworks() }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
