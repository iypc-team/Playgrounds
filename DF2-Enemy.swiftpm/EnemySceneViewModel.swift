// EnemySceneViewModel.swift
// Handles SceneKit scene setup, configuration, and animations for MVVM separation.
// 

import SwiftUI
import SceneKit

class EnemySceneViewModel: ObservableObject {
    @Published var sceneFailed = false
    let scene: SCNScene
    
    init() {
        if let loadedScene = SCNScene(named: "smooth_ship.scn") {
            self.scene = loadedScene
        } else {
            self.scene = SCNScene()
            sceneFailed = true
        }
        setupScene()
    }
    
    func setupScene() {
        // Create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        scene.rootNode.addChildNode(cameraNode)
        
        // Create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.position = SCNVector3(x: 0, y: 0, z: 500)
        scene.rootNode.addChildNode(ambientLightNode)
        
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
        
        // Retrieve and configure the enemy ship node
        guard let enemyShip = scene.rootNode.childNode(withName: "enemy", recursively: true) else {
            sceneFailed = true
            return
        }
        cameraNode.look(at: enemyShip.position)
        enemyShip.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.black
        enemyShip.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
        enemyShip.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
        enemyShip.addChildNode(cabinLightNode)
        
        // Animate the enemy ship
        let rotationDegrees = CGFloat(GLKMathDegreesToRadians(180))
        let action1 = SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)
        let action2 = SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)
        enemyShip.runAction(SCNAction.sequence([action1, action2]))
    }
    
    func configureView(_ scnView: SCNView) {
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.gray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        scnView.isTemporalAntialiasingEnabled = true
    }
}
