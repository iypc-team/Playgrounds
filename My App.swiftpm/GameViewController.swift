////
////  GameViewController.swift
////  3d Earth
////
////  Created by Ralph Admin on 10/14/18.
////  Copyright © 2018 IYPC Software. All rights reserved.
////
////  https://www.youtube.com/watch?v=3rpNDENQgPM
////
//
//import UIKit
//import QuartzCore
//import SceneKit
//
//class GameViewController: UIViewController
//{
//    var primaryScene: SCNScene!
//    var fighterScene: SCNScene!
//    
//    var scnView: SCNView!
//    
//    var fighterNode: SCNNode!
//    var engineEmitter: SCNNode!
//    var cameraNode: SCNNode!
//    var weapons: Weapons!
//    
//    override func viewDidLoad()
//    {
//        weapons = Weapons()
//        
//        super.viewDidLoad()
//        
//        primaryScene = SCNScene()
//        // fighterScene =  SCNScene(named: "art.scnassets/fighterPBR.scn")!
//        fighterScene =  SCNScene(named: "fighterPBR.scn")!
//        
//        cameraNode = SCNNode()
//        cameraNode.name = "mainCamera"
//        cameraNode.position = SCNVector3Make(0, 0, 15)
//        cameraNode.camera = SCNCamera()
//        cameraNode.camera!.automaticallyAdjustsZRange = true
//        primaryScene.rootNode.addChildNode(cameraNode)
//        
//        
//        
//        let starfield = Starfield()
//        starfield.addStarfield(scene: primaryScene)
//        
//        
//        
//        fighterNode = fighterScene.rootNode.childNode(withName: "fighter", recursively: true)!
//        fighterNode.position = SCNVector3Zero
//        weapons.addPhotonTorpedoNode(attachToNode: fighterNode)
//        weapons.addPhaserNode(attachToNode: fighterNode)
//
//        engineEmitter = fighterScene.rootNode.childNode(withName: "fighterEngineEmitter", recursively: true)!
//        print("engineEmitter: \(String(describing: engineEmitter))")
//        engineEmitter.geometry?.firstMaterial!.diffuse.contents = UIColor.clear
//        weapons.addEmitterNode(attachToNode: engineEmitter)
//        
//        fighterNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 2, z: 0, duration: 10)))
//        primaryScene.rootNode.addChildNode(fighterNode)
//
//        
//        
//        scnView = self.view as? SCNView
//        scnView.scene = primaryScene
//        scnView.allowsCameraControl = true
//        scnView.showsStatistics = false
//        
//        print()
//        primaryScene.rootNode.enumerateChildNodes { (child, stop) in
//            child.geometry?.firstMaterial?.lightingModel = .constant
//            print(child.name ?? "unnamed Item")
//        }
//    }
//    
//    override var shouldAutorotate: Bool { return true }
//    
//    override var prefersStatusBarHidden: Bool { return true }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
//    {
//        if UIDevice.current.userInterfaceIdiom == .phone { return .landscapeRight }
//        else if UIDevice.current.userInterfaceIdiom == .pad { return .landscapeRight }
//        else { return .all }
//    }
//    
//}
