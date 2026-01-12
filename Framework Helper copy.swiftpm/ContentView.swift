// Framework Helper copy  01/12/2026-1
//  for Grok Code Fast
//  https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
//  for GPT-5.1
//  

import SwiftUI

import SwiftUI

enum LoadState {
    case idle
    case loading
    case loaded([Framework])
    case empty
    case error(String)
}

struct ContentView: View {
    @State private var state: LoadState = .idle
    @State private var query = ""
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Libraries")
                .task {
                    await loadData()
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
        case .loaded(let frameworks):
            let filtered = frameworks.filter {
                query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
            }
            if filtered.isEmpty {
                emptyStateView(text: "No matches")
            } else {
                List(filtered) { framework in
                    NavigationLink(value: framework) {
                        Text(framework.name)
                    }
                }
                .navigationDestination(for: Framework.self) { framework in
                    FrameworkDetailView(framework: framework)
                }
                .searchable(text: $query)
            }
            
        case .empty:
            emptyStateView(text: "No frameworks available")
            
        case .error(let message):
            VStack(spacing: 12) {
                Text("Something went wrong").font(.headline)
                Text(message).font(.subheadline)
                Button("Retry") {
                    Task { await loadData() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
        }
    }
    
    @ViewBuilder
    private func emptyStateView(text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(text).font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    private func loadData() async {
        state = .loading
        do {
            // Replace with real async fetch if needed
            let frameworks = FrameworksConstants.sortedFrameworks()
            state = frameworks.isEmpty ? .empty : .loaded(frameworks)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

struct FrameworkDetailView: View {
    let framework: Framework
    
    var body: some View {
        VStack {
            Text(framework.name)
                .font(.largeTitle)
            // more detail UI here
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
