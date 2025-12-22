// 
// 
// 

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
            print(scene.physicsWorld.allBehaviors)
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
        
        let radarNode = SCNNode()
        radarNode.position 
        radarNode.geometry = SCNCone(topRadius: 1.0, bottomRadius: 256, height: 1024)
        
        scene.rootNode.addChildNode(radarNode)
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        print("ambientLightNode.position: \(ambientLightNode.position)")
        
        scene.rootNode.addChildNode(ambientLightNode)
    }
}
