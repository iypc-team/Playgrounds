//  GameViewController.swift
//   

import SwiftUI
import SceneKit

class GameViewController: UIViewController  {
    // ...
    
    override func loadView() {
        // Make sure our view is an SCNView to avoid cast crashes
        self.view = SCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        primaryScene = SCNScene()
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 6)
        primaryScene.rootNode.addChildNode(cameraNode)
        
        redMaterial = SCNMaterial()
        redMaterial.lightingModel = .constant
        redMaterial.diffuse.contents = UIColor.red
        
        darkGrayMaterial = SCNMaterial()
        darkGrayMaterial.lightingModel = .constant
        darkGrayMaterial.diffuse.contents = UIColor.darkGray
        
        blueMaterial = SCNMaterial()
        blueMaterial.lightingModel = .constant
        blueMaterial.diffuse.contents = UIColor.blue
        
        // Safely grab the SCNView
        guard let scnView = self.view as? SCNView else {
            assertionFailure("Expected SCNView")
            return
        }
        self.scnView = scnView
        
        scnView.scene = primaryScene
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.clear
        scnView.debugOptions = .showWireframe
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    // ...
}

//class GameViewController: UIViewController  {
//    var primaryScene: SCNScene = SCNScene.init()
//    var scnView: SCNView = SCNView.init()
//    
//    var octahedronNode: SCNNode = SCNNode.init()
//    var tetrahedronNode: SCNNode = SCNNode.init()
//    var tetrahedronNode_2: SCNNode = SCNNode.init()
//    
//    var geometryGenerator: GeometryGenerator!
//    
//    override func loadView() {
//        view = SCNView()
//    }
//    
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        
//        print()
//        
//        primaryScene = SCNScene()
//        
//        // Set up camera
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
//        cameraNode.look(at: SCNVector3(0, 0, 0))
//        cameraNode.camera?.automaticallyAdjustsZRange = true
//        primaryScene.rootNode.addChildNode(cameraNode)
//        
//        // Create and add lights to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.light!.color = UIColor.white
//        lightNode.position = SCNVector3(x: 0, y: 0, z: 100)
//        primaryScene.rootNode.addChildNode(lightNode)
//        
//        let lightNode2 = SCNNode()
//        lightNode2.light = SCNLight()
//        lightNode2.light!.type = .omni
//        lightNode2.light!.color = UIColor.white
//        lightNode2.position = SCNVector3(x: 0, y: 0, z: -100)
//        primaryScene.rootNode.addChildNode(lightNode2)
//        
//        // Create and add an ambient light to the scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = UIColor.gray
//        primaryScene.rootNode.addChildNode(ambientLightNode)
//        
//        geometryGenerator = GeometryGenerator()
//        
//        scnView = self.view as! SCNView
//        scnView.scene = primaryScene
//        scnView.antialiasingMode = .multisampling4X
//        scnView.allowsCameraControl = true
//        scnView.showsStatistics = false
//        scnView.backgroundColor = UIColor.black
//        scnView.autoenablesDefaultLighting = false  // Disabled to avoid conflict with custom lights
//        scnView.isTemporalAntialiasingEnabled = true
//        
//        // Generate and add octahedron
//        let octahedron = geometryGenerator.generateOctahedron()
//        primaryScene.rootNode.addChildNode(octahedron)
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        scnView.addGestureRecognizer(tapGesture)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) { 
//        
//    }
//    
//    
//    func generateTetrahedron() -> SCNNode {
//        return geometryGenerator.generateTetrahedron()
//    }
//    
//    func generateOctahedron() -> SCNNode {
//        return geometryGenerator.generateOctahedron()
//    }
//    
//    
//    @objc
//    func handleTap(_ gestureRecognize: UIGestureRecognizer)
//    {
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//        
//        // check what nodes are tapped
//        let p = gestureRecognize.location(in: scnView)
//        let hitResults = scnView.hitTest(p, options: [:])
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result = hitResults[0]
//            
//            // get its material
//            let material = result.node.geometry!.firstMaterial!
//            
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 2.5
//            
//            // on completion - unhighlight
//            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.0
//                
//                material.emission.contents = UIColor.black
//                
//                SCNTransaction.commit()
//            }
//            
//            material.emission.contents = UIColor.red
//            
//            SCNTransaction.commit()
//        }
//    }
//    
//    override var shouldAutorotate: Bool { return true }
//    
//    override var prefersStatusBarHidden: Bool { return true }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
//    {
//        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad { return .allButUpsideDown }
//        else { return .all }
//    }
//}
