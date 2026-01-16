//  GameViewController.swift
//  Icosahedron
//
//  Created by Ralph Admin on 10/7/18.
//  Copyright © 2018 IYPC Software. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView: SCNView!
    var primaryScene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        // Ensure the self.view is of type SCNView before casting
        guard let scnView = self.view as? SCNView else {
            fatalError("Expected the view to be of type SCNView")
        }
        self.scnView = scnView
        
        // Initialize SCNScene and set it as the SCNView's scene
        primaryScene = SCNScene()
        self.scnView.scene = primaryScene
        self.scnView.allowsCameraControl = true
        self.scnView.showsStatistics = false
        self.scnView.backgroundColor = .clear
        self.scnView.debugOptions = .showWireframe
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        primaryScene.rootNode.addChildNode(cameraNode)
    }
    
    override func loadView() {
        // Set up the SCNView as the primary view of the controller
        self.view = SCNView()
    }
}


