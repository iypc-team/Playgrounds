// Framework.swift

import Foundation

struct Framework: Identifiable, Hashable, Codable {
    
    let id: String
    let name: String
    let displayName: String
    
    /// Main initializer
    init(id: String? = nil, name: String, displayName: String? = nil) {
        self.name = name
        self.displayName = displayName ?? FrameworksConstants.displayName(for: name)
        self.id = id ?? FrameworksConstants.normalizedID(for: name)
    }
    
    /// Convenience initializer (most commonly used)
    init(name: String) {
        self.init(id: nil, name: name)
    }
    
    // MARK: - Hashable & Equatable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Framework, rhs: Framework) -> Bool {
        lhs.id == rhs.id
    }
}
