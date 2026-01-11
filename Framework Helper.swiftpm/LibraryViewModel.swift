// 
// 

import SwiftUI

class LibraryViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    @Published var searchText: String = ""
    
    // Complete list of known Apple frameworks for iOS development
    private let knownFrameworks = [
        "SwiftUI", "UIKit", "Foundation", "CoreData", "Combine", "ARKit", 
        "QuartzCore", "CoreGraphics", "CoreLocation", "MapKit", "AVFoundation", 
        "SpriteKit", "SceneKit", "Metal", "CoreML", "Vision", "HealthKit", 
        "WatchKit", "CloudKit", "StoreKit", "PassKit", "PushKit", "CallKit", 
        "EventKit", "HomeKit", "UserNotifications", "Contacts", "MetricKit", 
        "CreateML", "RealityKit", "NetworkExtension"
    ]
    
    var filteredFrameworks: [Framework] {
        if searchText.isEmpty {
            return frameworks
        } else {
            return frameworks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init() {
        fetchFrameworks()
    }
    
    func fetchFrameworks() {
        // Sort the frameworks alphabetically
        self.frameworks = knownFrameworks
            .map { Framework(name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
