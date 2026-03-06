// FrameworksConstants.swift
//
// Externalized framework list to Resources/frameworks.json for easier maintenance.
// Loads the list asynchronously to match the repository pattern.

import Foundation

struct FrameworksConstants {
    // Load frameworks from JSON resource, with fallback to empty array
    static func loadFrameworks() async throws -> [String] {
        let candidateBundles: [Bundle?] = [Bundle.module, Bundle.main]
        var fileURL: URL? = nil
        for b in candidateBundles.compactMap({ $0 }) {
            if let url = b.url(forResource: "frameworks", withExtension: "json") {
                fileURL = url
                break
            }
        }
        
        guard let url = fileURL else {
            // Fallback to empty if file not found
            return []
        }
        
        let data = try Data(contentsOf: url)
        let frameworks = try JSONDecoder().decode([String].self, from: data)
        return frameworks
    }
    
    /// Normalize a framework name into a stable ID.
    /// Uses a trimmed, lowercased form so IDs remain stable across runs.
    private static func normalizedID(for name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
    
    /// Create Framework instances from loaded list and return them sorted by name.
    static func sortedFrameworks() async throws -> [Framework] {
        let frameworks = try await loadFrameworks()
        return frameworks
            .map { Framework(id: normalizedID(for: $0), name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
