// MethodListView.swift
// 

import SwiftUI

struct MethodListView: View {
    let framework: Framework
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        self.framework = framework
        self._viewModel = StateObject(wrappedValue: MethodViewModel(frameworkName: framework.name))
    }
    
    var body: some View {
        List {
            SectionContent(title: "Methods", items: viewModel.methods, icon: "arrow.right.circle")
            SectionContent(title: "Properties", items: viewModel.properties, icon: "gear")
            SectionContent(title: "Constants", items: viewModel.constants, icon: "number")
            SectionContent(title: "Functions", items: viewModel.functions, icon: "f.cursive")
        }
        .navigationTitle(framework.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadMethods() }
        .overlay {
            if viewModel.isLoading {
                LoadingView(message: "Loading \(framework.displayName)…")
            } else if let error = viewModel.errorMessage {
                ErrorView(error: error) {
                    viewModel.clearError()
                    Task { await viewModel.loadMethods() }
                }
            }
        }
    }
}

// MARK: - Enhanced SectionContent with Copy All
private struct SectionContent: View {
    let title: String
    let items: [String]
    let icon: String
    
    @State private var copiedItem: String? = nil
    @State private var showCopiedAll = false
    
    private let itemFont: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        if !items.isEmpty {
            Section {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Button(action: copyAll) {
                        Label("Copy All", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
                
                ForEach(items, id: \.self) { item in
                    HStack {
                        Image(systemName: icon)
                            .foregroundStyle(.secondary)
                        Text(item)
                            .font(itemFont)
                            .textSelection(.enabled)
                        Spacer()
                        Button(action: { copyItem(item) }) {
                            Image(systemName: copiedItem == item ? "checkmark" : "doc.on.doc")
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .alert("Copied to Clipboard", isPresented: $showCopiedAll) {
                Button("OK") { }
            } message: {
                Text("\(items.count) \(title.lowercased()) copied.")
            }
        }
    }
    
    private func copyItem(_ item: String) {
        UIPasteboard.general.string = item
        copiedItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copiedItem = nil
        }
    }
    
    private func copyAll() {
        UIPasteboard.general.string = items.joined(separator: "\n")
        showCopiedAll = true
    }
}
