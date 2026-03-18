//  SceneModel.swift
//  Updated to centralize geometry inspection capabilities and synchronized scene handling
// red

import SceneKit
import Foundation

class SceneModel: ObservableObject {
    @Published var sceneName: String = "newFighter.scn"
    var enemyName: String = "smooth_ship.scn"
    
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 20)
    
    // New properties for fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    // Property for radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // Properties for lighting
    var lightIntensity: CGFloat = 750
    var omniLightIntensity: CGFloat = 5000
    var cabinLightColor: UIColor = UIColor.red
    var engineLightColor: UIColor = UIColor.green
    
    // Geometry inspection properties
    private var currentScene: SCNScene?
    
    // Set the current scene for inspection (to synchronize with SceneViewModel)
    func setScene(_ scene: SCNScene) {
        currentScene = scene
    }
    
    // Lists all SCNNode objects in the current scene recursively
    func listAllNodes() -> [SCNNode] {
        guard let scene = currentScene else { return [] }
        return scene.rootNode.childNodes(passingTest: { _, _ in true })
    }
    
    // Lists all SCNGeometry objects in the current scene
    func listAllGeometries() -> [SCNGeometry] {
        let nodes = listAllNodes()
        return nodes.compactMap { $0.geometry }
    }
    
    // Prints a summary of the scene's geometry
    func printGeometrySummary() {
        guard currentScene != nil else {
            print("No scene set for inspection.")
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
    
    // Generates a detailed inspection report as a string
    func generateInspectionReport(for sceneName: String) -> String {
        let nodes = listAllNodes()
        let geometries = listAllGeometries()
        let boundingBox = sceneBoundingBox()
        
        var results = "Scene: \(sceneName)\n"
        results += "Total Nodes: \(nodes.count)\n"
        results += "Nodes with Geometry: \(geometries.count)\n"
        
        if let box = boundingBox {
            results += "Bounding Box: Min(\(box.min.x), \(box.min.y), \(box.min.z)) Max(\(box.max.x), \(box.max.y), \(box.max.z))\n"
        }
        
        results += "\nGeometries:\n"
        for (index, geometry) in geometries.enumerated() {
            results += "\(index + 1). \(geometry.name ?? "Unnamed") - \(type(of: geometry))\n"
            results += "  Materials (\(geometry.materials.count)):\n"
            for (matIndex, material) in geometry.materials.enumerated() {
                results += "    \(matIndex + 1). \(material.name ?? "Unnamed Material")\n"
            }
        }
        
        return results
    }
    
    // Renames a geometry by index (0-based)
    func renameGeometry(at index: Int, to newName: String) {
        let geometries = listAllGeometries()
        guard index < geometries.count else {
            print("Geometry index \(index) is out of range.")
            return
        }
        geometries[index].name = newName
        print("Renamed geometry at index \(index) to '\(newName)'.")
    }
    
    // Gets the bounding box of the entire scene
    func sceneBoundingBox() -> (min: SCNVector3, max: SCNVector3)? {
        guard let scene = currentScene else { return nil }
        return scene.rootNode.boundingBox
    }
    
    // Creates a wireframe node representing the scene's bounding box
    func createBoundingBoxNode() -> SCNNode? {
        guard let box = sceneBoundingBox() else { return nil }
        let size = SCNVector3(box.max.x - box.min.x, box.max.y - box.min.y, box.max.z - box.min.z)
        let center = SCNVector3((box.max.x + box.min.x) / 2, (box.max.y + box.min.y) / 2, (box.max.z + box.min.z) / 2)
        
        let boxGeometry = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red  // Visible color for wireframe
        material.fillMode = .lines  // Wireframe mode
        boxGeometry.materials = [material]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "boundingBox"
        boxNode.position = center
        return boxNode
    }
    
    // Add more properties as needed
}
