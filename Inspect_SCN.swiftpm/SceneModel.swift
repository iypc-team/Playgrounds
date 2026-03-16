//  SceneModel.swift
//  Updated to include geometry inspection capabilities
//  

import SceneKit
import Foundation

class SceneModel: ObservableObject {
    @Published var sceneName: String = "newFighter.scn"  // Made @Published to trigger view updates
    var enemyName: String = "smooth_ship.scn"  // Fixed typo: 'enenyName' to 'enemyName'
    
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 20)
    
    // New properties for fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    // property for radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // properties for lighting
    var lightIntensity: CGFloat = 200
    var omniLightIntensity: CGFloat = 5000
    var cabinLightColor: UIColor = UIColor.red
    var engineLightColor: UIColor = UIColor.green
    
    // Geometry inspection properties
    private var currentScene: SCNScene?
    
    // Load the scene for inspection
    func loadSceneForInspection() -> SCNScene? {
        if let loadedScene = SCNScene(named: sceneName) {
            currentScene = loadedScene
            return loadedScene
        } else {
            print("Failed to load scene: \(sceneName)")
            currentScene = SCNScene() // Fallback
            print("currentScene: \(String(describing: currentScene))")
            return currentScene
        }
    }
    
    // Lists all SCNNode objects in the current scene recursively
    func listAllNodes() -> [SCNNode] {
        guard let scene = currentScene ?? loadSceneForInspection() else { return [] }
        return scene.rootNode.childNodes(passingTest: { _, _ in true })
    }
    
    // Lists all SCNGeometry objects in the current scene
    func listAllGeometries() -> [SCNGeometry] {
        let nodes = listAllNodes()
        return nodes.compactMap { $0.geometry }
    }
    
    // Prints a summary of the scene's geometry
    func printGeometrySummary() {
        guard let _ = currentScene ?? loadSceneForInspection() else {
            print("No scene loaded.")
            return
        }
        
        let nodes = listAllNodes()
        let geometries = listAllGeometries()
        
        print("Scene Geometry Summary for '\(sceneName)':")
        print("- Total Nodes: \(nodes.count)")
        print("- Nodes with Geometry: \(geometries.count)")
        
        for (index, geometry) in geometries.enumerated() {
            print("  Geometry \(index + 1): \(geometry.name ?? "Unnamed") - Type: \(type(of: geometry))")
        }
    }
    
    // Gets the bounding box of the entire scene
    func sceneBoundingBox() -> (min: SCNVector3, max: SCNVector3)? {
        guard let scene = currentScene ?? loadSceneForInspection() else { return nil }
        return scene.rootNode.boundingBox
    }
    
    // Add more properties as needed
}
