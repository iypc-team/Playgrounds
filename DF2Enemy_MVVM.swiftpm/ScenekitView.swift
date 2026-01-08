//  
//
// 

import SwiftUI
import SceneKit

struct ScenekitView: UIViewRepresentable {
    @ObservedObject var viewModel: SceneViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = viewModel.setupScene()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Configure view properties
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.gray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        scnView.isTemporalAntialiasingEnabled = true
    }
}

