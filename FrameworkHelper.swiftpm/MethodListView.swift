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
            SectionContent(title: "Types", items: viewModel.types, icon: "cube")
            SectionContent(title: "Initializers", items: viewModel.initializers, icon: "plus.circle")
            SectionContent(title: "Methods", items: viewModel.methods, icon: "arrow.right.circle")
            SectionContent(title: "Properties", items: viewModel.properties, icon: "gear")
            SectionContent(title: "Constants", items: viewModel.constants, icon: "number")
            SectionContent(title: "Free Functions", items: viewModel.freeFunctions, icon: "f.cursive")
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

// MARK: - Enhanced SectionContent (Always Shows Header)

private struct SectionContent: View {
    let title: String
    let items: [String]
    let icon: String
    
    @State private var copiedItem: String? = nil
    
    private let itemFont: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        Section {
            if items.isEmpty {
                Text("No \(title.lowercased()) available for this framework")
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            } else {
                // Copy All button
                HStack {
                    Spacer()
                    Button(action: copyAll) {
                        Label("Copy All", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
                
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: icon)
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        
                        Text(item)
                            .font(itemFont)
                            .textSelection(.enabled)
                            .lineLimit(nil)
                        
                        Spacer()
                        
                        Button(action: { copyItem(item) }) {
                            Image(systemName: copiedItem == item ? "checkmark.circle.fill" : "doc.on.doc")
                                .foregroundStyle(copiedItem == item ? .green : .blue)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 2)
                }
            }
        } header: {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(.none)
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
        guard !items.isEmpty else { return }
        UIPasteboard.general.string = items.joined(separator: "\n")
    }
}
