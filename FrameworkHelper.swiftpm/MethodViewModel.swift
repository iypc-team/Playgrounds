// MethodViewModel.swift
// 

import Foundation

@MainActor
final class MethodViewModel: ObservableObject {
    let frameworkName: String
    
    @Published var types: [String] = []
    @Published var initializers: [String] = []
    @Published var methods: [String] = []
    @Published var properties: [String] = []
    @Published var constants: [String] = []
    @Published var freeFunctions: [String] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: any FrameworksRepository
    private var loadTask: Task<Void, Never>?
    
    init(frameworkName: String, repository: any FrameworksRepository = StaticFrameworksRepository()) {
        self.frameworkName = frameworkName
        self.repository = repository
    }
    
    func loadMethods() async {
        guard loadTask == nil else { return }
        
        loadTask = Task {
            await loadMethodsInternal()
            loadTask = nil
        }
    }
    
    private func loadMethodsInternal() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await loadJSONData()
            let allMethods = try JSONDecoder().decode([String: FrameworkMethods].self, from: data)
            
            if let entry = allMethods[frameworkName] {
                self.types         = entry.types
                self.initializers  = entry.initializers
                self.methods       = entry.methods
                self.properties    = entry.properties
                self.constants     = entry.constants
                self.freeFunctions = entry.freeFunctions
            } else {
                // Fallback for frameworks not in JSON
                self.types         = []
                self.initializers  = []
                self.methods       = defaultEntries(for: frameworkName)
                self.properties    = []
                self.constants     = []
                self.freeFunctions = []
            }
        } catch {
            errorMessage = "Failed to load methods: \(error.localizedDescription)"
            self.methods = defaultEntries(for: frameworkName)
        }
        
        isLoading = false
    }
    
    private func loadJSONData() async throws -> Data {
        guard let url = Bundle.main.url(forResource: "methods", withExtension: "json") else {
            throw NSError(domain: "MethodViewModel", 
                          code: 404, 
                          userInfo: [NSLocalizedDescriptionKey: "methods.json file not found in bundle"])
        }
        
        return try Data(contentsOf: url)
    }
    
    private func defaultEntries(for framework: String) -> [String] {
        // You can expand this if needed
        return ["Check Apple Documentation for \(framework)"]
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - JSON Data Model

struct FrameworkMethods: Codable {
    let types: [String]
    let initializers: [String]
    let methods: [String]
    let properties: [String]
    let constants: [String]
    let freeFunctions: [String]
    
    enum CodingKeys: String, CodingKey {
        case types, initializers, methods, properties, constants
        case freeFunctions = "freeFunctions"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.types         = try container.decodeIfPresent([String].self, forKey: .types) ?? []
        self.initializers  = try container.decodeIfPresent([String].self, forKey: .initializers) ?? []
        self.methods       = try container.decodeIfPresent([String].self, forKey: .methods) ?? []
        self.properties    = try container.decodeIfPresent([String].self, forKey: .properties) ?? []
        self.constants     = try container.decodeIfPresent([String].self, forKey: .constants) ?? []
        self.freeFunctions = try container.decodeIfPresent([String].self, forKey: .freeFunctions) ?? []
    }
}
