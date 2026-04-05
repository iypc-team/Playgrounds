// UtilityFunctions.swift
// Utility functions for handling SceneKit scenes and related data.

import SceneKit

class UtilityFunctions {
    let selectedScene: String
    let scene: SCNScene
    
    init(selectedScene: String, scene: SCNScene) {
        self.selectedScene = selectedScene
        self.scene = scene
        print(selectedScene)
        print()
        
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
        // Assuming a list of valid scenes similar to ContentView
        let validScenes = ["fighter.scn", "fighterPBR.scn", "newFighter_2.scn", "ship.scn", "smooth_ship.scn"]
        return validScenes.contains(selectedScene)
    }
    
    // Retrieves and lists all unique materials from geometries in the selected scene
    func getMaterials() -> [SCNMaterial] {
        var materials = Set<SCNMaterial>()
        
        // Traverse all child nodes recursively to find geometries with materials
        scene.rootNode.enumerateChildNodes { node, _ in
            // error occurs on line 42 in UtilityFunctions.swift
            if let geometry = node.geometry, let geometryMaterials = geometry.materials {
                materials.formUnion(geometryMaterials)
            }
        }
        
        return Array(materials)
    }
    
    // Add more utility functions as needed
}
