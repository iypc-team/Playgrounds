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
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        print("ambientLightNode.position: \(ambientLightNode.position)")
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        let radarNode = SCNNode()
        radarNode.geometry = SCNCone(topRadius: 3, bottomRadius: 0.5, height: 25)
        radarNode.position = SCNVector3(x: -2.5, y: 16.5, z: 0)  // Move it farther in front of the camera
        radarNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        print("radarNode.position: \(radarNode.position)")
        scene.rootNode.addChildNode(radarNode)
    }
}
