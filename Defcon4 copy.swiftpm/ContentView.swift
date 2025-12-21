//  Defcon4 copy 12/21/2024-initial commit
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4.swiftpm
 */
// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        VStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel  // Added to access model properties
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.scene?.background.contents = UIColor.lightGray
        scnView.allowsCameraControl = true  
        scnView.autoenablesDefaultLighting = false  // Disable default lighting to avoid conflicts with custom lights
        scnView.antialiasingMode = .multisampling4X
        
        // Add this to scale the fighter node
        if let fighterNode = scene.rootNode.childNode(withName: "fighter", recursively: true) {
            fighterNode.scale = sceneModel.fighterScale  // Use model value
            
            // Optional: Keep the green light but reduce intensity to balance with ambient
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.light?.color = UIColor.green
            lightNode.light?.intensity = sceneModel.omniLightIntensity  // Use model value
            
            fighterNode.addChildNode(lightNode)
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update view if scene changes
    }
}
