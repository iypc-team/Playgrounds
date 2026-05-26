// MethodListView.swift

import SwiftUI

struct MethodListView: View {
    
    let framework: Framework
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        self.framework = framework
        self._viewModel = StateObject(
            wrappedValue: MethodViewModel(frameworkName: framework.name)
        )
    }
    
    var body: some View {
        List {
            SectionContent(title: "Methods",    items: viewModel.methods,    icon: "arrow.right.circle")
            SectionContent(title: "Properties", items: viewModel.properties, icon: "gear")
            SectionContent(title: "Constants",  items: viewModel.constants,  icon: "number")
            SectionContent(title: "Functions",  items: viewModel.functions,  icon: "f.cursive")
        }
        .navigationTitle(framework.displayName)
        .navigationBarTitleDisplayMode(.inline)
        // ✅ FIX: trigger data load when the view appears
        .task {
            await viewModel.loadMethods()
        }
        // Show a loading spinner while fetching
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading \(framework.displayName)…")
                    .progressViewStyle(.circular)
            }
        }
        // Surface any load errors
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
    }
}

// MARK: - Reusable Section View

private struct SectionContent: View {
    let title: String
    let items: [String]
    let icon: String
    
    private let itemFont: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: icon)
                        .font(itemFont)
                        .textSelection(.enabled)
                }
            } header: {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .textCase(.uppercase)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MethodListView(framework: Framework(name: "CoreMotion"))
    }
}
