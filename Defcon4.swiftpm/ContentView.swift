//  Defcon4 12/19/2025-3
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
//                .frame(height: 400)
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
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling2X
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update view if scene changes
    }
}
