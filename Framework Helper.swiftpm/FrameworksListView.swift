// 
// 

import Foundation

//
// 

import Foundation

class FrameworksViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    
    // Complete list of known Apple frameworks for iOS development
    private let knownFrameworks = [
        "SwiftUI",
        "UIKit",
        "Foundation",
        "CoreData",
        "Combine",
        "ARKit",
        "QuartzCore", // Core Animation
        "CoreGraphics", // Core Graphics (Quartz)
        "CoreLocation",
        "MapKit",
        "AVFoundation",
        "SpriteKit",
        "SceneKit",
        "Metal",
        "CoreML",
        "Vision",
        "HealthKit",
        "WatchKit",
        "CloudKit",
        "StoreKit",
        "PassKit",
        "PushKit",
        "CallKit",
        "EventKit",
        "HomeKit",
        "UserNotifications",
        "Contacts",
        "MetricKit",
        "CreateML",
        "RealityKit",
        "NetworkExtension"
    ]
    
    func fetchFrameworks() {
        // Use the known list instead of loaded frameworks
        self.frameworks = knownFrameworks.map { Framework(name: $0) }
    }
}

//class FrameworksViewModel: ObservableObject {
//    @Published var frameworks: [Framework] = []
//    
//    func fetchFrameworks() {
//        // Fetching all frameworks
//        let bundles = Bundle.allFrameworks
//        self.frameworks = bundles.compactMap { bundle in
//            // Extracting the framework name
//            guard let name = bundle.bundlePath.components(separatedBy: "/").last else {
//                return nil
//            }
//            return Framework(name: name)
//        }
//    }
//}

