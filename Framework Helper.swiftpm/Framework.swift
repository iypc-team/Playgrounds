// Framework.swift
//
// Use a stable identifier derived from the framework name to avoid
// unstable identities (UUID) that break List diffing and navigation.

import Foundation

struct Framework: Identifiable, Hashable, Codable {
    /// Stable identifier derived from the framework's name.
    /// Using the name (or a normalized form of it) ensures the identity
    /// stays consistent across recreations.
    let id: String
    let name: String
    
    init(id: String? = nil, name: String) {
        self.name = name
        // Default id is the name trimmed and normalized to a consistent form.
        // Adjust normalization if you need different uniqueness rules.
        self.id = id ?? name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Convenience initializer when you only have a name.
    init(name: String) {
        self.init(id: nil, name: name)
    }
}
