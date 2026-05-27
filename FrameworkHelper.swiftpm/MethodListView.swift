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
        .task {
            await viewModel.loadMethods()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading \(framework.displayName)…")
                    .progressViewStyle(.circular)
            }
        }
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
    
    @State private var copiedItem: String? = nil
    
    private let itemFont: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Label(item, systemImage: icon)
                            .font(itemFont)
                            .textSelection(.enabled)
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = item
                            copiedItem = item
                            // Reset the checkmark after 1.5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                if copiedItem == item {
                                    copiedItem = nil
                                }
                            }
                        } label: {
                            Image(systemName: copiedItem == item ? "checkmark.circle.fill" : "doc.on.doc")
                                .foregroundStyle(copiedItem == item ? .green : .secondary)
                                .animation(.easeInOut(duration: 0.2), value: copiedItem)
                        }
                        .buttonStyle(.borderless)
                    }
                    // Long-press context menu as an alternative
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = item
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
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
