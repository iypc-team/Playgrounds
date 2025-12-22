//  Defcon4 12/22/2024-4
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4.swiftpm
 */
// ContentView.swift

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        VStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel  // Added to access model properties
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.scene?.background.contents = UIColor.lightGray
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        
        guard let fighterNode = scene.rootNode.childNode(withName: "fighter", recursively: true) else {
            print("Warning: Fighter node not found in scene.")
            return scnView
        }
        
        fighterNode.scale = sceneModel.fighterScale
        
        // Configure and add light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.green
        lightNode.light?.intensity = sceneModel.omniLightIntensity
        fighterNode.addChildNode(lightNode)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update view if scene changes
    }
}
