//  SceneViewModel.swift
//  

import SwiftUI
import SceneKit
import Foundation

class SceneViewModel: ObservableObject {
    
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    @Published var isRotating: Bool = false
    @Published var isFighterRotating: Bool = false
    @Published var fighterNode: SCNNode?
    private var rotationAction: SCNAction?
    private var fighterRotationAction: SCNAction?
    
    init() {
        
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene  // Update to loaded scene if available
            // Find and store the fighter node
            if let fighter = scene.rootNode.childNode(withName: "fighter", recursively: true) {
                self.fighterNode = fighter
                fighterRotationAction = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 20)
            }
        } else {
            print("loadedScene did not")
        }
        setupScene()  // Configure camera and lights
    }
    
    public func setupScene() {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup radar node
        let radarNode = SCNNode()
        radarNode.position = sceneModel.radarPosition  // Fix: Assign position from model
        radarNode.geometry = SCNCone(topRadius: 1.0, bottomRadius: 256, height: 1024)
        radarNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        scene.rootNode.addChildNode(radarNode)
        
        // Prepare rotation action for later use
        rotationAction = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 2.0)
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func startRotation() {
        guard !isRotating, let action = rotationAction else { return }
        let repeatRotation = SCNAction.repeatForever(action)
        if let radarNode = scene.rootNode.childNodes.first(where: { $0.geometry is SCNCone }) {
            radarNode.runAction(repeatRotation)
            isRotating = true
        }
    }
    
    func stopRotation() {
        if let radarNode = scene.rootNode.childNodes.first(where: { $0.geometry is SCNCone }) {
            radarNode.removeAllActions()
            isRotating = false
        }
    }
    
    func startFighterRotation() {
        guard let node = fighterNode, let action = fighterRotationAction, !isFighterRotating else { return }
        let repeatAction = SCNAction.repeatForever(action)
        node.runAction(repeatAction)
        isFighterRotating = true
    }
    
    func stopFighterRotation() {
        if let node = fighterNode {
            node.removeAllActions()
            isFighterRotating = false
        }
    }
    
    private func positionRadarNode(_ radarNode: SCNNode) {
        guard let geometry = radarNode.geometry else { 
            print("Radar node has no geometry.")
            
            return 
        }
        
        let boundingBox = geometry.boundingBox
        var length = boundingBox.max.y - boundingBox.min.y  // Operate on y-axis only
        length += length / 2.5
        
        sceneModel.radarPosition = SCNVector3(x: 0.0, y: length / 2.0, z: 0)
        print("sceneModel.radarPosition: \(sceneModel.radarPosition)")
    }
}
