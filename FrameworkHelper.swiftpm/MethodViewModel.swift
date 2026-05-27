// MethodViewModel.swift

import Foundation

@MainActor
final class MethodViewModel: ObservableObject {
    
    @Published var methods: [String] = []
    @Published var properties: [String] = []
    @Published var constants: [String] = []
    @Published var functions: [String] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let frameworkName: String
    private var loadTask: Task<Void, Never>?
    
    init(frameworkName: String) {
        self.frameworkName = frameworkName
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
            let allMethods = try JSONDecoder().decode([String: MethodEntry].self, from: data)
            
            if let entry = allMethods[frameworkName] {
                self.methods     = entry.methods
                self.properties  = entry.properties
                self.constants   = entry.constants
                self.functions   = entry.functions
            } else {
                // Fallback for frameworks not yet present in the JSON.
                self.methods     = defaultEntries(for: frameworkName)
                self.properties  = []
                self.constants   = []
                self.functions   = []
            }
        } catch {
            errorMessage = "Failed to load methods: \(error.localizedDescription)"
            self.methods = defaultEntries(for: frameworkName)
        }
        
        isLoading = false
    }
    
    private func loadJSONData() async throws -> Data {
        // Data(contentsOf:) is synchronous but acceptable here — source is always
        // a local bundle resource so there is no network latency risk.
        let candidateBundles: [Bundle?] = [Bundle.module, Bundle.main]
        for bundle in candidateBundles.compactMap({ $0 }) {
            if let url = bundle.url(forResource: "methods", withExtension: "json") {
                return try Data(contentsOf: url)
            }
        }
        throw NSError(
            domain: "MethodViewModel",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "methods.json not found"]
        )
    }
    
    // ✅ clearError() keeps all @Published mutation inside the ViewModel, not in the view.
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Fallback Data
    
    private func defaultEntries(for framework: String) -> [String] {
        switch framework {
        case "CoreMotion":
            return [
                "CMMotionManager()",
                "startDeviceMotionUpdates()",
                "startAccelerometerUpdates()",
                "startGyroUpdates()",
                "stopDeviceMotionUpdates()",
                "isDeviceMotionAvailable",
                "deviceMotion"
            ]
        default:
            return ["No reference data available for \(framework)"]
        }
    }
}

// MARK: - Supporting Model

struct MethodEntry: Decodable {
    let methods: [String]
    let properties: [String]
    let constants: [String]
    let functions: [String]
}
