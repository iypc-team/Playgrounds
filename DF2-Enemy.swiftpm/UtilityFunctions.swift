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

        collectMaterials(from: scene.rootNode, into: &materials)

        return Array(materials)
    }

    private func collectMaterials(from node: SCNNode, into materials: inout Set<SCNMaterial>) {
        if let geometry = node.geometry {
            materials.formUnion(geometry.materials)
        }

        for childNode in node.childNodes {
            collectMaterials(from: childNode, into: &materials)
        }
    }
    
    // Add more utility functions as needed
}
