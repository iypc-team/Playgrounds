// 
// length:

// Updated SceneViewModel.swift
import SwiftUI
import SceneKit
import Foundation

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    init() {
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene  // Update to loaded scene if available
            print(" loadedScene: \(loadedScene)")
            print("scene.physicsWorld.allBehaviors: \(scene.physicsWorld.allBehaviors )")
        }
        
        setupScene()  //  configure camera and lights
    }
    
    public func setupScene() {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        print("cameraNode.position: \(cameraNode.position) ")
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup radar node with dynamic positioning
        let radarNode = SCNNode()
        radarNode.name = "radar"  // Add this line to name the node
        radarNode.geometry = SCNCone(topRadius: 3, bottomRadius: 0.5, height: 50)
        radarNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        print("ambientLightNode.position: \(ambientLightNode.position)\n")
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func positionRadarNode(_ radarNode: SCNNode) {
        guard let geometry = radarNode.geometry else { return }
        
        let boundingBox = geometry.boundingBox
        var length = boundingBox.max.y - boundingBox.min.y  // Operate on y-axis only
        length += length / 2.5
        print("length: \(length)")
        sceneModel.radarPosition = SCNVector3(x: 0.0, y: length / 2.0, z: 0) 
    }
}
