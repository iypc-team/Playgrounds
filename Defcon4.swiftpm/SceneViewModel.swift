import SwiftUI
import SceneKit

class SceneViewModel: ObservableObject {
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    
    init() {
        self.sceneModel = SceneModel()
        self.selectedNode = nil
        //  'self' used in property access 'sceneModel' before all stored properties are initialized
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene
        } else {
            self.scene = SCNScene()
        }
        setupScene()
    }
    
    public func setupScene() {
        // Clear existing nodes to avoid duplicates on re-setup
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
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
