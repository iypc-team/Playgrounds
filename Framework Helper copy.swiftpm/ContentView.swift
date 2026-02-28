//  Framework Helper copy  02/28/2026-4
//  ContentView.swift
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper%20copy.swiftpm
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
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task { await viewModel.load() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.frameworks.isEmpty {
                    Text("No libraries available")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.frameworks) { framework in
                        NavigationLink(value: framework) {
                            FrameworkRow(framework: framework)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(Text("Libraries"))
            .navigationDestination(for: Framework.self) { framework in
                MethodListView(framework: framework)
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
