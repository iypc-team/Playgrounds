// MethodViewModel.swift
//
// Updated to remove side-effects from init, use JSONDecoder with proper error handling,
// and protect against concurrent fetches. The view should call `fetchMethods()` (e.g. in .task).

import SwiftUI

@MainActor
final class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let framework: Framework
    
    // Built‑in defaults so the list never stays empty
    private let defaultMethods: [String: [String]] = [
        "SwiftUI": [
            "Text(_:)", "Image(_:)", "Button(_:action:)",
            "VStack(alignment:spacing:content:)", "HStack(alignment:spacing:content:)",
            "ZStack(alignment:content:)", "List(_:rowContent:)",
            "NavigationStack(_:)", "NavigationLink(_:value:)"
        ],
        "UIKit": [
            "UIView.init(frame:)", "UIViewController.viewDidLoad()",
            "UIViewController.present(_:animated:completion:)", "UITableView.init(frame:style:)"
        ],
        "Foundation": [
            "Date()", "URL.init(string:)", "Data.init(contentsOf:)",
            "JSONDecoder.decode(_:from:)"
        ],
        "Combine": [
            "Just.init(_:)", "Publisher.map(_:)", "Publisher.sink(receiveCompletion:receiveValue:)"
        ]
    ]
    
    // Guard to avoid concurrent loads
    private var currentLoadTask: Task<Void, Never>?
    
    init(framework: Framework) {
        self.framework = framework
        // No side-effects here (no automatic fetch). Let the view trigger fetchMethods().
    }
    
    /// Fetch methods for the framework.
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
                // Attempt to load JSON from bundle (expects { "SwiftUI": [...], ... })
                if let url = Bundle.main.url(forResource: "methods", withExtension: "json") {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode([String: [String]].self, from: data)
                    
                    // Respect cancellation
                    if Task.isCancelled { return }
                    
                    if let loaded = decoded[currentLibrary] {
                        await MainActor.run {
                            self.methods = loaded
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
                self.methods = self.defaultMethods[currentLibrary] ?? ["No methods available for this framework"]
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
