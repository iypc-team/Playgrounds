// UtilityFunctions.swift
// Utility functions for handling SceneKit scenes and related data.

import SceneKit

class UtilityFunctions {
    static let validScenes = ["fighter.scn", "fighterPBR.scn", "newFighter_2.scn", "ship.scn", "smooth_ship.scn"]
    
    let selectedScene: String
    let scene: SCNScene
    
    init(selectedScene: String, scene: SCNScene) {
        self.selectedScene = selectedScene
        self.scene = scene
        print(selectedScene)
        print()
        let _ = getSceneRootNode
    }
    
    // Example utility methods
    func getSceneFileName() -> String {
        print(selectedScene)
        return selectedScene
    }
    
    func getSceneRootNode() -> SCNNode {
        print(scene.rootNode.geometry as Any)
        return scene.rootNode
    }
    
    func isValidScene() -> Bool {
        return Self.validScenes.contains(selectedScene)
    }
    
    // Retrieves and lists all unique materials from geometries in the selected scene
    func getMaterials() -> [SCNMaterial] {
        var materials = Set<SCNMaterial>()
        
        // Traverse all child nodes recursively to find geometries with materials
        scene.rootNode.enumerateChildNodes { node, _ in
            if let geometry = node.geometry {
                materials.formUnion(geometry.materials) // Removed unnecessary "if let"
            }
        }
        return Array(materials)
    }
    
    // Add more utility functions as needed
}
