// EnemySceneViewModel.swift
// Handles SceneKit scene setup, configuration, and animations for MVVM separation.
// print

import SwiftUI
import SceneKit

class EnemySceneViewModel: ObservableObject {
    private enum MaterialAppearance {
        // These aliases come from different bundled .scn assets that describe the
        // same visual surfaces with different material names.
        static let diffuseContentsByName: [String: UIColor] = [
            // Exterior-style materials
            "exterior": .black,
            "black_exterior": .black,
            "black_material": .black,

            // Transparent window materials
            "windows": .clear,

            // Engine glow materials
            "engine": .cyan,
            "engine_material": .cyan,
            "engine_emission_material": .cyan
        ]
    }

    @Published var sceneFailed = false
    @Published var scene: SCNScene
    
    @Published var selectedScene: String = "smooth_ship.scn" {
        didSet {
            loadScene()
        }
    }
    
    // Holds the UtilityFunctions instance
    @Published var utility: UtilityFunctions?
    
    init() {
        self.scene = SCNScene()
        loadScene()
    }
    
    private func loadScene() {
        if let loadedScene = SCNScene(named: selectedScene) {
            self.scene = loadedScene
            sceneFailed = false
            setupScene()
            // Initialize UtilityFunctions after scene setup
            self.utility = UtilityFunctions(selectedScene: selectedScene, scene: scene)
            // Print configured materials to console after utility is initialized
            if let materials = self.utility?.getMaterials() {
                configureMaterials(materials)
                print("Configured materials (\(materials.count)): \(materials.map { $0.name ?? "Unnamed Material" })")
                for material in materials {
                    print("material.isDoubleSided \(material.isDoubleSided)")
                    print("material.name:  \(String(describing: material.name))")
                    print("material.diffuse:  \(String(describing: material.diffuse.contents))\n")
                }
            }
        } else {
            self.scene = SCNScene()
            sceneFailed = true
            self.utility = nil
        }
    }
    
    private func findEnemyNode() -> SCNNode? {
        // First, try the standard "enemy" node name
        if let node = scene.rootNode.childNode(withName: "enemy", recursively: true) {
            return node
        }
        
        // Fallback: Try scene-specific names based on file names
        let possibleNames = ["ship", "fighter", "newFighter_2"]
        for name in possibleNames {
            if let node = scene.rootNode.childNode(withName: name, recursively: true) {
                return node
            }
        }
        
        // Last resort: Find the first child node with geometry (assuming it's the main model)
        if scene.rootNode.geometry != nil {
            return scene.rootNode
        }

        var geometryNode: SCNNode?
        scene.rootNode.enumerateChildNodes { node, stop in
            guard node.geometry != nil else {
                return
            }

            geometryNode = node
            stop.pointee = true
        }

        return geometryNode
    }
    
    func setupScene() {
        // Create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        scene.rootNode.addChildNode(cameraNode)
        
        // Create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.position = SCNVector3(x: 0, y: 0, z: 500)
        //        scene.rootNode.addChildNode(ambientLightNode)
        
        // Create and add lights to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 100)
        scene.rootNode.addChildNode(lightNode)
        
        let lightNode2 = SCNNode()
        lightNode2.light = SCNLight()
        lightNode2.light!.type = .omni
        lightNode2.position = SCNVector3(x: 0, y: 0, z: -100)
        scene.rootNode.addChildNode(lightNode2)
        
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.light!.type = .omni
        cabinLightNode.light!.color = UIColor.red
        cabinLightNode.light!.intensity = 1000
        cabinLightNode.light!.castsShadow = false
        cabinLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // Retrieve and configure the enemy ship node (using flexible search)
        if let enemyShip = findEnemyNode() {
            cameraNode.look(at: enemyShip.position)
            enemyShip.addChildNode(cabinLightNode)
            
            // Animate the enemy ship
            //            let rotationDegrees = CGFloat(GLKMathDegreesToRadians(180))
            //            let action1 = SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)
            //            let action2 = SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)
            //            enemyShip.runAction(SCNAction.sequence([action1, action2]))
        } else {
            print("No enemy node found.")
            // No suitable node found; camera remains at default position
        }
    }
    
    func configureView(_ scnView: SCNView) {
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.gray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        scnView.isTemporalAntialiasingEnabled = true
    }

    private func configureMaterials(_ materials: [SCNMaterial]) {
        for material in materials {
            material.isDoubleSided = true

            // Normalize SceneKit material names to lowercase so the lookup stays
            // consistent across assets that use mixed-case naming.
            guard let materialName = material.name?.lowercased() else {
                continue
            }

            // Leave unknown materials unchanged so each scene can retain any
            // asset-specific materials that are not part of this shared styling.
            if let diffuseContents = MaterialAppearance.diffuseContentsByName[materialName] {
                material.diffuse.contents = diffuseContents
            }
        }
    }
}
