// 
// 

import Foundation

struct FrameworksConstants {
    // Complete list of known Apple frameworks for iOS development
    static let knownFrameworks = [
        "SwiftUI", "UIKit", "Foundation", "CoreData", "Combine", "ARKit", 
        "QuartzCore", "CoreGraphics", "CoreLocation", "MapKit", "AVFoundation", 
        "SpriteKit", "SceneKit", "Metal", "CoreML", "Vision", "HealthKit", 
        "WatchKit", "CloudKit", "StoreKit", "PassKit", "PushKit", "CallKit", 
        "EventKit", "HomeKit", "UserNotifications", "Contacts", "MetricKit", 
        "CreateML", "RealityKit", "NetworkExtension"
    ]
    
    // Shared utility to create and sort frameworks
    static func sortedFrameworks() -> [Framework] {
        return knownFrameworks
            .map { Framework(name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
