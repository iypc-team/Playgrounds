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
    
    // Add more utility functions as needed
}
