//  GameViewController.swift
//   polyhedron

import SwiftUI
import SceneKit

class GameViewController: UIViewController  {
    var primaryScene: SCNScene!
    var scnView: SCNView!
    var redMaterial: SCNMaterial!
    var darkGrayMaterial: SCNMaterial!
    var blueMaterial: SCNMaterial!
    
    var geometryGenerator: GeometryGenerator!
    
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
        
        geometryGenerator = GeometryGenerator()
        
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
        scnView.backgroundColor = UIColor.black
        scnView.debugOptions = .showWireframe
        
        let polyhedron = geometryGenerator.generateDodecahedron()
        primaryScene.rootNode.addChildNode(polyhedron)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        print("UITapGestureRecognizer ")
        // Retrieve the SCNView from the gesture
        let scnView = self.view as! SCNView
        
        // Check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        
        // Check that we clicked on at least one object
        if hitResults.count > 0 {
            // Retrieved the first clicked object
            let result = hitResults[0]
            print("result: \(result)")
                  
            // Get its material
            let material = result.node.geometry!.firstMaterial!
            print("material: \(material )\n")
            
            // Highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // On completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
}

