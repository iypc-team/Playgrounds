//  Defcon4 12/24/2024-1
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4.swiftpm
 */
// red
// ContentView.swift

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("3D Fighter Scene")
    }
}

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    var sceneModel: SceneModel
    
    private let lightColor = UIColor.green
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.scene?.background.contents = UIColor.black
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        
        configureFighterNode(in: scnView)
        
        return scnView
    }
    
    private func configureFighterNode(in scnView: SCNView) {
        guard let node = scene.rootNode.childNode(withName: "fighter", recursively: true) else {
            print("Warning: Fighter node not found in scene.")
            return
        }
        node.scale = sceneModel.fighterScale
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = sceneModel.omniLightColor
        lightNode.light?.intensity = sceneModel.omniLightIntensity
        node.addChildNode(lightNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        print("func updateUIView")
        // Re-scale fighter and update light if sceneModel changed
        configureFighterNode(in: uiView)
    }
}

#Preview {
    ContentView()
}
