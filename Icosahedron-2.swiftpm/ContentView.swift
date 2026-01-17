//  Icosahedron-2  01/17/2026-5
//  Copyright © 2018 IYPC Software. All rights reserved.
// 
//  https://github.com/iypc-team/Playgrounds/tree/main/Icosahedron-2.swiftpm
//  fighter.scn

import SwiftUI
import SceneKit
import GLKit
import UIKit

struct SceneKitView : UIViewRepresentable {
    let gvc = GameViewController()
    let radianConversion = CGFloat(GLKMathDegreesToRadians(360.0))
    
    var primaryScene = SCNScene()
    
    
    func makeUIView(context: Context) -> SCNView {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        cameraNode.camera?.automaticallyAdjustsZRange = true
        primaryScene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene
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
        
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        primaryScene.rootNode.addChildNode(ambientLightNode)
        
//        let ship = gvc.generateTetrahedron()
        let ship = gvc.generateOctahedron()
        primaryScene.rootNode.addChildNode(ship)
        
        return scnView
    }
    
    let scnView = SCNView()
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = primaryScene
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // other items
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
        
    }
}


struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
            .preferredColorScheme(.dark)
    }
}
