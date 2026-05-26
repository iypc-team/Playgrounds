// FrameworksConstants.swift

import Foundation

struct FrameworksConstants {
    
    // MARK: - Display Name Mapping
    
    static func displayName(for framework: String) -> String {
        switch framework {
        case "CoreMotion":
            return "Core Motion"
        case "CoreLocation":
            return "Core Location"
        case "UserNotifications":
            return "User Notifications"
        case "CoreData":
            return "Core Data"
        case "CoreGraphics":
            return "Core Graphics"
        case "AVFoundation":
            return "AV Foundation"
        case "MapKit":
            return "MapKit"
        case "HealthKit":
            return "HealthKit"
        case "CloudKit":
            return "CloudKit"
        case "StoreKit":
            return "StoreKit"
        case "PassKit":
            return "PassKit"
        case "PushKit":
            return "PushKit"
        case "CallKit":
            return "CallKit"
        case "EventKit":
            return "EventKit"
        case "HomeKit":
            return "HomeKit"
        case "Contacts":
            return "Contacts"
        case "MetricKit":
            return "MetricKit"
        case "CreateML":
            return "Create ML"
        case "RealityKit":
            return "RealityKit"
        case "NetworkExtension":
            return "Network Extension"
        case "UniformTypeIdentifiers":
            return "Uniform Type Identifiers"
        default:
            return framework
        }
    }
    
    // MARK: - ID Normalization
    
    /// Normalize a framework name into a stable ID.
    /// Made internal (not private) so Framework.swift can access it.
    static func normalizedID(for name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
    
    // MARK: - Framework Loading
    
    static func loadFrameworks() async throws -> [String] {
        let candidateBundles: [Bundle?] = [Bundle.module, Bundle.main]
        var fileURL: URL? = nil
        
        for bundle in candidateBundles.compactMap({ $0 }) {
            if let url = bundle.url(forResource: "frameworks", withExtension: "json") {
                fileURL = url
                break
            }
        }
        
        guard let url = fileURL else {
            return []
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([String].self, from: data)
    }
    
    static func sortedFrameworks() async throws -> [Framework] {
        let frameworks = try await loadFrameworks()
        
        return frameworks
            .map { name in
                Framework(name: name)
            }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }
}
