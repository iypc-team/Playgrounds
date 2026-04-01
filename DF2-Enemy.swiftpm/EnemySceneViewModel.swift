// EnemySceneViewModel.swift
// Handles SceneKit scene setup, configuration, and animations for MVVM separation.
// 

import SwiftUI
import SceneKit

class EnemySceneViewModel: ObservableObject {
    let scene = SCNScene(named: "smooth_ship.scn")!
    
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
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.light!.type = .omni
        engineLightNode.light!.color = UIColor.red
        engineLightNode.light!.intensity = 7000 * 4
        engineLightNode.light!.castsShadow = true
        engineLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // Retrieve and configure the enemy ship node
        let enemyShip = scene.rootNode.childNode(withName: "enemy", recursively: true)!
        cameraNode.look(at: enemyShip.position)
        enemyShip.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.black
        enemyShip.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear
        enemyShip.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
        enemyShip.addChildNode(engineLightNode)
        
        // Animate the enemy ship
        let rotationDegrees = CGFloat(GLKMathDegreesToRadians(45.0))
        let action1 = SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)
        let wait = SCNAction.wait(duration: 2)
        let action2 = SCNAction.rotate(by: rotationDegrees, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4)
        enemyShip.runAction(SCNAction.sequence([action1, wait, action2]))
    }
    
    func configureView(_ scnView: SCNView) {
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.gray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}

