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
        // ✅ LoadingView replaces the inline ProgressView overlay.
        // ✅ ErrorView replaces the fragile .alert(isPresented: .constant(...)) pattern.
        //    ErrorView exposes a retry action so the user can recover without leaving the screen.
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
                            copyToClipboard(item)
                            copiedItem = item
                            // ✅ Task.sleep replaces DispatchQueue.main.asyncAfter —
                            //    structured concurrency, no escaping closure needed.
                            Task {
                                try? await Task.sleep(for: .seconds(1.5))
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
                    .contextMenu {
                        Button {
                            copyToClipboard(item)
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
    
    // MARK: - Clipboard Helper
    
    /// Writes `text` to the system clipboard.
    /// ✅ #if canImport guard ensures this compiles on macOS as well as iOS.
    private func copyToClipboard(_ text: String) {
#if canImport(UIKit)
        UIPasteboard.general.string = text
#elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
#endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MethodListView(framework: Framework(name: "CoreMotion"))
    }
}
