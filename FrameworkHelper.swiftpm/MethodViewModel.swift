// MethodViewModel.swift
//
// Improved version: Better task cancellation, defensive JSON loading,
// consistent error handling, and alignment with LibraryViewModel patterns.

import Foundation
import SwiftUI

@MainActor
final class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    @Published var properties: [String] = []
    @Published var constants: [String] = []
    @Published var functions: [String] = []
    
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let framework: Framework
    
    // Built-in defaults so UI is never empty
    private let defaultEntries: [String: (methods: [String], properties: [String], constants: [String], functions: [String])] = [
        "SwiftUI": (
            methods: ["Text(_:)", "Image(systemName:)", "Button(action:label:)", "VStack(alignment:spacing:content:)", "NavigationStack(_:)", "sheet(isPresented:onDismiss:content:)", "task(priority:operation:)"],
            properties: [".body", ".padding", ".background", ".foregroundColor", ".frame(width:height:)", ".environment", ".state"],
            constants: ["ForEach", "Group", "VStack", "HStack", "ZStack", "Spacer", "Divider"],
            functions: ["Spacer()", "Divider()"]
        ),
        "UIKit": (
            methods: ["UIView.addSubview(_:)", "UIViewController.viewDidLoad()", "UIViewController.present(_:animated:completion:)", "UINavigationController.pushViewController(_:animated:)"],
            properties: ["UIView.backgroundColor", "UIView.frame", "UILabel.text", "UIButton.titleLabel"],
            constants: ["UIControl.State", "UIView.ContentMode"],
            functions: []
        ),
        "Foundation": (
            methods: ["Date()", "JSONDecoder.decode(_:from:)", "URL(string:)"],
            properties: [],
            constants: [],
            functions: []
        )
    ]
    
    private var currentLoadTask: Task<Void, Never>?
    
    init(framework: Framework) {
        self.framework = framework
    }
    
    /// Fetch methods for the framework
    func fetchMethods() async {
        if currentLoadTask != nil { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                if Task.isCancelled { return }
                
                let loaded = try await self.loadFromJSON()
                
                await MainActor.run {
                    self.applyData(loaded)
                }
            } catch {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
        
        currentLoadTask = task
        await task.value
        
        await MainActor.run {
            self.isLoading = false
            self.currentLoadTask = nil
        }
    }
    
    func cancelFetch() {
        currentLoadTask?.cancel()
        currentLoadTask = nil
        
        Task { @MainActor in
            self.isLoading = false
        }
    }
    
    // MARK: - Private
    
    private func loadFromJSON() async throws -> FrameworkMethods {
        let candidateBundles = [Bundle.module, Bundle.main]
        
        for bundle in candidateBundles {
            if let url = bundle.url(forResource: "methods", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([String: FrameworkMethods].self, from: data)
                return decoded[framework.name] ?? FrameworkMethods()
            }
        }
        
        // No JSON file found → will fall back to defaults
        return FrameworkMethods()
    }
    
    private func applyData(_ data: FrameworkMethods) {
        methods = !data.methods.isEmpty ? uniquePreservingOrder(data.methods) : defaultFor(\.methods)
        properties = !data.properties.isEmpty ? uniquePreservingOrder(data.properties) : defaultFor(\.properties)
        constants = !data.constants.isEmpty ? uniquePreservingOrder(data.constants) : defaultFor(\.constants)
        functions = !data.functions.isEmpty ? uniquePreservingOrder(data.functions) : defaultFor(\.functions)
    }
    
    private func defaultFor(_ keyPath: KeyPath<(methods: [String], properties: [String], constants: [String], functions: [String]), [String]>) -> [String] {
        defaultEntries[framework.name]?[keyPath: keyPath] ?? []
    }
    
    private func uniquePreservingOrder(_ array: [String]) -> [String] {
        var seen = Set<String>()
        return array.filter { seen.insert($0).inserted }
    }
}

// MARK: - Supporting Model

struct FrameworkMethods: Codable {
    var methods: [String] = []
    var properties: [String] = []
    var constants: [String] = []
    var functions: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case methods, properties, constants, functions
    }
}
