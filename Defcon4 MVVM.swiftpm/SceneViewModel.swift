// 
// 

import Foundation
import SceneKit

class SceneViewModel: ObservableObject {
    // Observable property to notify the view of changes
    @Published var sceneModel: SceneModel
    
    init(sceneName: String) {
        // Initialize SceneModel
        self.sceneModel = SceneModel(sceneName: sceneName, cameraPosition: SCNVector3(x: 0, y: 0, z: 20))
    }
    
    // Functions to manipulate the SceneModel or interact with the view
    func updateCameraPosition(_ position: SCNVector3) {
        sceneModel.cameraNode?.position = position
    }
    
    func addLightNode(light: SCNNode) {
        sceneModel.lightNodes.append(light)
        sceneModel.scene?.rootNode.addChildNode(light)
    }
}
