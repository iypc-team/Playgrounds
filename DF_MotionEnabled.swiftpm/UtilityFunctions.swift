// UtilityFunctions.swift
// 

import SceneKit

/// A utility class for debugging SceneKit scenes and motion data.
class UtilityFunctions {
    
    static func printSceneLoadingStatus(sceneFileName: String, loaded: SCNScene?) {
        print("printSceneLoadingStatus()")
        if loaded != nil {
            print("Loaded \(sceneFileName) successfully\n")
        } else {
            print("Failed to load \(sceneFileName)\n")
        }
    }
    
    /// Recursively prints the hierarchy of a SceneKit node, including geometry presence.
    /// - Parameters:
    ///   - node: The root node to start printing from.
    ///   - indent: Indentation string for nested levels (used internally).
    static func printNodeHierarchy(_ node: SCNNode, indent: String = "") {
        print("printNodeHierarchy()")
        let hasGeometry = node.geometry != nil ? "Yes" : "No"
        print("\(indent)\(node.name ?? "Unnamed") - Geometry: \(hasGeometry)")
        for child in node.childNodes {
            printNodeHierarchy(child, indent: indent + "  ")
        }
        print()
    }
    
    /// Logs a quaternion for debugging.
    /// - Parameters:
    ///   - quat: The SCNVector4 representing the quaternion.
    ///   - label: A descriptive label for the log.
    static func logQuaternion(_ quat: SCNVector4, label: String = "Quaternion") {
        print("\(label): (\(quat.x), \(quat.y), \(quat.z), \(quat.w))")
    }
    
    // Add more utility methods here as needed, e.g., for performance profiling
}
