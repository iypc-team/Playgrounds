// MethodViewModel.swift
//
// Decode the actual Resources/methods.json shape and expose separate published lists
// for methods, properties, constants and functions. Uses Bundle.module to load the
// packaged resource, falls back to defaults, and preserves concurrency/error handling.

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
    
    // Built‑in per-category defaults so the UI never stays empty
    private let defaultEntries: [String: (methods: [String], properties: [String], constants: [String], functions: [String])] = [
        "SwiftUI": (
            methods: [
                "Text(_:)", "Text(verbatim:)", "Image(systemName:)", "Button(action:label:)",
                "VStack(alignment:spacing:content:)", "HStack(alignment:spacing:content:)", "ZStack(alignment:content:)",
                "List(_:rowContent:)", "ForEach(_:content:)", "NavigationStack(_:)", "NavigationLink(_:value:)",
                "sheet(isPresented:onDismiss:content:)", "fullScreenCover(isPresented:content:)", "task(priority:operation:)",
                "onAppear(perform:)", "onDisappear(perform:)", "toolbar(content:)", "alert(_:isPresented:actions:message:)"
            ],
            properties: [
                ".body", ".environmentObject", ".environment", ".state", ".binding", ".observedObject", ".sceneStorage",
                ".frame(width:height:)", ".background", ".foregroundColor", ".opacity", ".padding", ".cornerRadius",
                ".listStyle", ".navigationBarTitle", ".sheet", ".alert"
            ],
            constants: [
                "ForEach", "Group", "NavigationView", "List", "VStack", "HStack", "ZStack", "Spacer()", "Divider()",
                "TextField", "Button"
            ],
            functions: [
                "Spacer()", "Divider()", "TextField", "Button"
            ]
        ),
        "UIKit": (
            methods: [
                "UIView.init(frame:)", "UIView.addSubview(_:)", "UIView.layoutIfNeeded()", "UIView.setNeedsLayout()",
                "UIViewController.viewDidLoad()", "UIViewController.viewWillAppear(_:)", "UIViewController.viewDidAppear(_:)",
                "UIViewController.present(_:animated:completion:)", "UIViewController.dismiss(animated:completion:)",
                "UINavigationController.pushViewController(_:animated:)", "UINavigationController.popViewController(animated:)"
            ],
            properties: [
                "UIView.backgroundColor", "UIView.frame", "UIView.bounds", "UIView.alpha", "UIViewController.view",
                "UIViewController.navigationController", "UILabel.text", "UITextField.text", "UIButton.titleLabel",
                "UIImageView.image", "UIScrollView.contentOffset"
            ],
            constants: [
                "UILabel.textAlignment", "UIControl.State", "UIView.ContentMode"
            ],
            functions: []
        ),
        "Foundation": (
            methods: [
                "Date()", "DateFormatter.string(from:)", "URL.init(string:)", "URLComponents.init()", "Data(contentsOf:)",
                "JSONDecoder.decode(_:from:)", "JSONEncoder.encode(_:)", "UserDefaults.standard.set(_:forKey:)"
            ],
            properties: [],
            constants: [],
            functions: []
        )
        // Add additional defaults if you need them
    ]
    
    // Guard to avoid concurrent loads
    private var currentLoadTask: Task<Void, Never>?
    
    init(framework: Framework) {
        self.framework = framework
        // No side-effects here; view triggers fetchMethods()
    }
    
    /// Fetch per-category entries for the framework.
    /// If a load is already in progress this returns immediately.
    func fetchMethods() async {
        // Prevent starting a second concurrent load
        if currentLoadTask != nil { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            let currentLibrary = self.framework.name
            
            struct FrameworkEntry: Codable {
                let methods: [String]?
                let properties: [String]?
                let constants: [String]?
                let functions: [String]?
            }
            
            var loadedMethods: [String]? = nil
            var loadedProperties: [String]? = nil
            var loadedConstants: [String]? = nil
            var loadedFunctions: [String]? = nil
            
            do {
                // Prefer Bundle.module for package resources; fallback to Bundle.main
                let candidateBundles: [Bundle?] = [Bundle.module, Bundle.main]
                var fileURL: URL? = nil
                for b in candidateBundles.compactMap({ $0 }) {
                    if let url = b.url(forResource: "methods", withExtension: "json") {
                        fileURL = url
                        break
                    }
                }
                
                if let url = fileURL {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode([String: FrameworkEntry].self, from: data)
                    
                    if Task.isCancelled { return }
                    
                    if let entry = decoded[currentLibrary] {
                        func uniquePreservingOrder(_ arr: [String]?) -> [String] {
                            guard let arr = arr else { return [] }
                            var seen = Set<String>()
                            return arr.filter { seen.insert($0).inserted }
                        }
                        
                        loadedMethods = uniquePreservingOrder(entry.methods)
                        loadedProperties = uniquePreservingOrder(entry.properties)
                        loadedConstants = uniquePreservingOrder(entry.constants)
                        loadedFunctions = uniquePreservingOrder(entry.functions)
                    }
                }
            } catch {
                // Capture a friendly error but continue to fallback
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
            
            // Apply loaded values or fall back to defaults
            await MainActor.run {
                if let m = loadedMethods, !m.isEmpty { self.methods = m }
                else { self.methods = self.defaultEntries[currentLibrary]?.methods ?? ["No methods available for this framework"] }
                
                if let p = loadedProperties, !p.isEmpty { self.properties = p }
                else { self.properties = self.defaultEntries[currentLibrary]?.properties ?? [] }
                
                if let c = loadedConstants, !c.isEmpty { self.constants = c }
                else { self.constants = self.defaultEntries[currentLibrary]?.constants ?? [] }
                
                if let f = loadedFunctions, !f.isEmpty { self.functions = f }
                else { self.functions = self.defaultEntries[currentLibrary]?.functions ?? [] }
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
    
    /// Cancel an in-flight fetch.
    func cancelFetch() {
        currentLoadTask?.cancel()
        currentLoadTask = nil
        
        Task { @MainActor in
            self.isLoading = false
        }
    }
}
