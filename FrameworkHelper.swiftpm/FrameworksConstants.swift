// FrameworksConstants.swift
// 

import Foundation

struct FrameworksConstants {
    
    // MARK: - Categories
    static let categories: [String: [String]] = [
        "UI Frameworks": ["SwiftUI", "UIKit"],
        "Core Frameworks": ["Foundation", "Combine", "CoreData"],
        "Graphics & Media": ["CoreGraphics", "QuartzCore", "AVFoundation", "Metal", "RealityKit"],
        "System & Hardware": ["CoreMotion", "CoreLocation", "HealthKit", "EventKit"],
        "Data & Cloud": ["CloudKit", "NetworkExtension"],
        "Other": ["MapKit", "StoreKit", "UserNotifications", "Contacts", "MetricKit"]
    ]
    
    // MARK: - Load Frameworks from JSON
    static func loadFrameworks() -> [Framework] {
        guard let url = Bundle.main.url(forResource: "frameworks", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let names = try? JSONDecoder().decode([String].self, from: data) else {
            return fallbackFrameworks()
        }
        
        return names.map { Framework(name: $0) }
    }
    
    private static func fallbackFrameworks() -> [Framework] {
        ["SwiftUI", "UIKit", "Foundation", "CoreData", "Combine", "CoreMotion"]
            .map { Framework(name: $0) }
    }
    
    // MARK: - Display Name
    static func displayName(for framework: String) -> String {
        switch framework {
        case "CoreMotion": return "Core Motion"
        case "CoreLocation": return "Core Location"
        case "UserNotifications": return "User Notifications"
        case "CoreData": return "Core Data"
        case "CoreGraphics": return "Core Graphics"
        case "AVFoundation": return "AV Foundation"
        case "NetworkExtension": return "Network Extension"
        case "CreateML": return "Create ML"
        case "MetricKit": return "MetricKit"
        default: return framework
        }
    }
    
    // MARK: - Normalized ID (Required by Framework.swift)
    static func normalizedID(for name: String) -> String {
        // Clean name for stable ID (removes spaces, makes lowercase)
        return name
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
    }
}
