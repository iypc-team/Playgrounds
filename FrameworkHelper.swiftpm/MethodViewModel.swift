// MethodViewModel.swift
//
// Updated to parse the new JSON structure: each library key maps to an object with
// "methods", "properties", "constants", and "functions" arrays. The view calls
// `fetchMethods()` (e.g. in .task) to populate all four published categories.

import SwiftUI

/// Decodable model matching the per-library object in methods.json.
struct FrameworkEntries: Decodable {
    var methods: [String]
    var properties: [String]
    var constants: [String]
    var functions: [String]
}

@MainActor
final class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    @Published var properties: [String] = []
    @Published var constants: [String] = []
    @Published var functions: [String] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let framework: Framework
    
    // Built-in defaults so the list never stays empty
    private let defaultEntries: [String: FrameworkEntries] = [
        "SwiftUI": FrameworkEntries(
            methods: ["Text(_:)", "Image(_:)", "Button(_:action:)",
                      "VStack(alignment:spacing:content:)", "HStack(alignment:spacing:content:)",
                      "ZStack(alignment:content:)", "List(_:rowContent:)",
                      "NavigationStack(_:)", "NavigationLink(_:value:)"],
            properties: ["body", "padding", "foregroundColor(_:)", "font(_:)"],
            constants: [".leading", ".trailing", ".center", ".largeTitle"],
            functions: ["withAnimation(_:_:)", "GeometryReader(content:)"]
        ),
        "UIKit": FrameworkEntries(
            methods: ["UIView.init(frame:)", "UIViewController.viewDidLoad()",
                      "UIViewController.present(_:animated:completion:)", "UITableView.init(frame:style:)"],
            properties: ["UIView.frame", "UIView.backgroundColor", "UIView.isHidden"],
            constants: ["UIColor.systemBackground", "UIFont.systemFont(ofSize:)"],
            functions: ["UIGraphicsBeginImageContextWithOptions(_:_:_:)"]
        ),
        "Foundation": FrameworkEntries(
            methods: ["Date()", "URL.init(string:)", "Data.init(contentsOf:)",
                      "JSONDecoder.decode(_:from:)"],
            properties: ["UserDefaults.standard", "Bundle.main", "Date.now"],
            constants: ["NSNotFound", "URLSession.shared"],
            functions: ["NSLocalizedString(_:comment:)", "print(_:separator:terminator:)"]
        ),
        "Combine": FrameworkEntries(
            methods: ["Just.init(_:)", "Publisher.map(_:)", "Publisher.sink(receiveCompletion:receiveValue:)"],
            properties: ["CurrentValueSubject.value", "Publisher.eraseToAnyPublisher()"],
            constants: ["RunLoop.main", "DispatchQueue.main"],
            functions: ["Publishers.CombineLatest(_:_:)"]
        )
    ]
    
    // Guard to avoid concurrent loads
    private var currentLoadTask: Task<Void, Never>?
    
    init(framework: Framework) {
        self.framework = framework
        // No side-effects here (no automatic fetch). Let the view trigger fetchMethods().
    }
    
    /// Fetch methods, properties, constants, and functions for the framework.
    /// If a load is already in progress this returns immediately.
    func fetchMethods() async {
        // Prevent starting a second concurrent load
        if currentLoadTask != nil { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            // Mark loading state on the main actor
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            let currentLibrary = self.framework.name
            
            do {
                // Attempt to load JSON from bundle (expects { "LibraryName": { "methods": [...], ... }, ... })
                if let url = Bundle.main.url(forResource: "methods", withExtension: "json") {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode([String: FrameworkEntries].self, from: data)
                    
                    // Respect cancellation
                    if Task.isCancelled { return }
                    
                    if let loaded = decoded[currentLibrary] {
                        await MainActor.run {
                            self.methods = loaded.methods
                            self.properties = loaded.properties
                            self.constants = loaded.constants
                            self.functions = loaded.functions
                        }
                        return
                    }
                }
            } catch {
                // If JSON loading/decoding fails, capture a friendly error but continue to fallback
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
            
            // Fallback to built-in defaults (or a friendly message)
            await MainActor.run {
                if let defaults = self.defaultEntries[currentLibrary] {
                    self.methods = defaults.methods
                    self.properties = defaults.properties
                    self.constants = defaults.constants
                    self.functions = defaults.functions
                } else {
                    self.methods = ["No methods available for this framework"]
                    self.properties = []
                    self.constants = []
                    self.functions = []
                }
            }
        }
        
        currentLoadTask = task
        
        // Wait for completion so callers awaiting fetchMethods() observe the final state
        await task.value
        
        // Ensure we clear loading state and task reference (handle cancellation)
        await MainActor.run {
            self.isLoading = false
            self.currentLoadTask = nil
        }
    }
    
    /// Cancel an in-flight fetch (if any).
    func cancelFetch() {
        currentLoadTask?.cancel()
        currentLoadTask = nil
        
        Task { @MainActor in
            self.isLoading = false
        }
    }
}
