// InspectModelGeometry.swift
// 

import SceneKit

/// A standalone class for inspecting the geometry of a loaded SceneKit scene.
class InspectModelGeometry {
    private var scene: SCNScene?
    
    /// Initializes the inspector with a scene loaded by name.
    /// - Parameter sceneName: The name of the .scn file to load (without extension).
    init(sceneName: String) {
        // Load the scene using the same method as SceneViewModel
        if let loadedScene = SCNScene(named: sceneName) {
            self.scene = loadedScene
        } else {
            print("Failed to load scene: \(sceneName)")
            self.scene = SCNScene() // Fallback to empty scene
        }
    }
    
    /// Initializes the inspector with an existing SCNScene.
    /// - Parameter scene: The SceneKit scene to inspect.
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    /// Lists all SCNNode objects in the scene recursively.
    func listAllNodes() -> [SCNNode] {
        guard let scene = scene else { return [] }
        return scene.rootNode.childNodes(passingTest: { _, _ in true })
    }
    
    /// Lists all SCNGeometry objects in the scene.
    func listAllGeometries() -> [SCNGeometry] {
        let nodes = listAllNodes()
        return nodes.compactMap { $0.geometry }
    }
    
    /// Prints a summary of the scene's geometry.
    func printGeometrySummary() {
        guard let scene = scene else { 
            // Value 'scene' was defined but never used. replace with boolean test. Show fully updated InspectModelGeometry.swift code snippet
            print("No scene loaded.")
            return
        }
        
        let nodes = listAllNodes()
        let geometries = listAllGeometries()
        
        print("Scene Geometry Summary:")
        print("- Total Nodes: \(nodes.count)")
        print("- Nodes with Geometry: \(geometries.count)")
        
        for (index, geometry) in geometries.enumerated() {
            print("  Geometry \(index + 1): \(geometry.name ?? "Unnamed") - Type: \(type(of: geometry))")
        }
    }
    
    /// Gets the bounding box of the entire scene.
    func sceneBoundingBox() -> (min: SCNVector3, max: SCNVector3)? {
        guard let scene = scene else { return nil }
        return scene.rootNode.boundingBox
    }
}
