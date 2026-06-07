// RotationSpeed.swift

import Foundation

enum RotationSpeed: Float, CaseIterable {
    case off    = 0.0
    case slow   = 0.15
    case medium = 0.3
    case fast   = 0.6
    
    var displayName: String {
        switch self {
        case .off:    return "Off"
        case .slow:   return "Slow"
        case .medium: return "Medium"
        case .fast:   return "Fast"
        }
    }
}

