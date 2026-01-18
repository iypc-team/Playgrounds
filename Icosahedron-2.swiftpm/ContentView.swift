//  Icosahedron-2  01/18/2026-1
//  Copyright © 2018 IYPC Software. All rights reserved.
//
//  https://github.com/iypc-team/Playgrounds/tree/main/Icosahedron-2.swiftpm
//  
//  

import SwiftUI
import SceneKit
import UIKit

struct SceneKitView: UIViewRepresentable {
    private let gameViewController = GameViewController()
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let primaryScene = SCNScene()
        
        // Set up camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        cameraNode.camera?.automaticallyAdjustsZRange = true
        primaryScene.rootNode.addChildNode(cameraNode)
        
        // Create and add lights to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light!.color = UIColor.white
        lightNode.position = SCNVector3(x: 0, y: 0, z: 100)
        primaryScene.rootNode.addChildNode(lightNode)
        
        let lightNode2 = SCNNode()
        lightNode2.light = SCNLight()
        lightNode2.light!.type = .omni
        lightNode2.light!.color = UIColor.white
        lightNode2.position = SCNVector3(x: 0, y: 0, z: -100)
        primaryScene.rootNode.addChildNode(lightNode2)
        
        // Create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        primaryScene.rootNode.addChildNode(ambientLightNode)
        
        // Generate and add octahedron, handling potential nil
        // Initializer for conditional binding must have Optional type, not 'SCNNode'
        if let ship = gameViewController.generateOctahedron() {
            primaryScene.rootNode.addChildNode(ship)
        } else {
            // Fallback: Could add a default shape or log an error
            print("Failed to generate octahedron")
        }
        
        scnView.scene = primaryScene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Configure the view
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.black
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false  // Disabled to avoid conflict with custom lights
        scnView.isTemporalAntialiasingEnabled = true
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
            .preferredColorScheme(.dark)
    }
}
