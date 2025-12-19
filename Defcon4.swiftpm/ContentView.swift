//  Defcon4 12/19/2025-1
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
            // 'scene' is inaccessable due to 'private' protection level
                .frame(height: 400)
            //            Spacer()
            //            HStack {
            //                Button("Change Light Intensity") {
            //                    viewModel.sceneModel.lightIntensity = 500.0
            //                    viewModel.setupScene()  // Re-setup if needed
            //                }
            //                
            //                Button("Select Node") {
            //                    // Simulate selecting a node (extend ViewModel for tap gestures)
            //                    if let node = viewModel.scene.rootNode.childNodes.first {
            //                        viewModel.selectedNode = node
            //                    }
            //                }
            //                
            //                if viewModel.selectedNode != nil {
            //                    Button("Change Color") {
            //                        viewModel.updateNodeColor(node: viewModel.selectedNode!, color: .blue)
            //                    }
            //                }
            //            }
        }
    }
}

import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = true  // Enable user interaction if desired
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling2X
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update view if scene changes
    }
}
