//  FrameworkHelper 05/27/2026-4
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/FrameworkHelper.swiftpm

import SwiftUI

struct ContentView: View {
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
            .searchable(text: $viewModel.searchText, prompt: "Search frameworks")
            .onChange(of: viewModel.searchText) { _ in
                viewModel.applySearchFilter()
            }
            .refreshable {
                await viewModel.loadFrameworks()
            }
            .task {
                await viewModel.loadFrameworks()
            }
            // Category Picker
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("All Categories") {
                            viewModel.selectedCategory = nil
                            viewModel.applySearchFilter()
                        }
                        ForEach(Array(FrameworksConstants.categories.keys).sorted(), id: \.self) { category in
                            Button(category) {
                                viewModel.selectedCategory = category
                                viewModel.applySearchFilter()
                            }
                        }
                    } label: {
                        Label("Categories", systemImage: "folder")
                    }
                }
            }
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

#Preview {
    ContentView()
}
