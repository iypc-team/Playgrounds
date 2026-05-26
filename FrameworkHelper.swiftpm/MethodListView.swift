// MethodListView.swift

import SwiftUI

struct MethodListView: View {
    
    let framework: Framework
    @StateObject private var viewModel: MethodViewModel
    
    // Updated initializer - accepts Framework, not String
    init(framework: Framework) {
        self.framework = framework
        self._viewModel = StateObject(
            wrappedValue: MethodViewModel(frameworkName: framework.name)
        )
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
    }
}

// MARK: - Reusable Section View

private struct SectionContent: View {
    let title: String
    let items: [String]
    let icon: String
    
    // Customize the font here
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
