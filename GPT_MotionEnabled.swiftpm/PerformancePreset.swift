// PerformancePreset.swift

import SceneKit

enum PerformancePreset: String, CaseIterable, Identifiable {
    case low, medium, high
    
    var id: String { rawValue }
    
    var motionUpdateInterval: TimeInterval {
        switch self {
        case .low:    return 1.0 / 30.0
        case .medium: return 1.0 / 60.0
        case .high:   return 1.0 / 120.0
        }
    }
    
    var uiThrottleInterval: TimeInterval { 0.033 } // ~30 Hz UI updates
    
    var antialiasingMode: SCNAntialiasingMode {
        switch self {
        case .low:    return .none
        case .medium: return .multisampling2X
        case .high:   return .multisampling4X
        }
    }
    
    var temporalAntialiasing: Bool { self != .low }
    var showsStatistics: Bool { self == .high }
    
    var displayName: String {
        switch self {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        }
    }
}
