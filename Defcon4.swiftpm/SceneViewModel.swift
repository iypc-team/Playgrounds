import SwiftUI
import SceneKit

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    init() {
        self.scene = SCNScene()  // Initialize with default empty scene
        self.sceneModel = SceneModel()  // Initialize SceneModel
        
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene  // Update to loaded scene if available
        }
    }
    
    public func setupScene() {
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambientLightNode)
        
    }
    
    func updateNodeColor(node: SCNNode, color: UIColor) {
        node.geometry?.firstMaterial?.diffuse.contents = color
        objectWillChange.send()  // Ensure UI updates for non-@Published changes
    }
}
