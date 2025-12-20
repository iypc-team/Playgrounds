//  Defcon4 12/20/2024-1
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4.swiftpm
 */
// 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        VStack {
            SceneKitView(scene: viewModel.scene)
//                .frame(maxWidth: 200, maxHeight: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.scene?.background.contents = UIColor.lightGray
        scnView.allowsCameraControl = true  
        scnView.autoenablesDefaultLighting = false  // Disable default lighting to avoid conflicts with custom lights
        scnView.antialiasingMode = .multisampling4X
        
        // Add this to scale the fighter node
        if let fighterNode = scene.rootNode.childNode(withName: "fighter", recursively: true) {
            fighterNode.scale = SCNVector3(x: 1.5, y: 1.5, z: 1.5)  // Adjust scale as needed
            
            // Optional: Keep the green light but reduce intensity to balance with ambient
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.light?.color = UIColor.green
            lightNode.light?.intensity = 5000.0
            
            fighterNode.addChildNode(lightNode)
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update view if scene changes
    }
}
