// FrameworksConstants.swift
//
// Produces Framework instances with stable IDs derived from the framework name.

import Foundation

struct FrameworksConstants {
    // Complete list of known Apple frameworks for iOS development
    static let knownFrameworks: [String] = [
        "SwiftUI", "UIKit", "Foundation", "CoreData", "Combine", "ARKit",
        "QuartzCore", "CoreGraphics", "CoreLocation", "MapKit", "AVFoundation",
        "SpriteKit", "SceneKit", "Metal", "CoreML", "Vision", "HealthKit",
        "WatchKit", "CloudKit", "StoreKit", "PassKit", "PushKit", "CallKit",
        "EventKit", "HomeKit", "UserNotifications", "Contacts", "MetricKit",
        "CreateML", "RealityKit", "NetworkExtension", "UniformTypeIdentifiers"
    ]
    
    /// Normalize a framework name into a stable ID.
    /// Uses a trimmed, lowercased form so IDs remain stable across runs.
    private static func normalizedID(for name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
    
    /// Create Framework instances with stable IDs and return them sorted by name.
    static func sortedFrameworks() -> [Framework] {
        knownFrameworks
            .map { Framework(id: normalizedID(for: $0), name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
