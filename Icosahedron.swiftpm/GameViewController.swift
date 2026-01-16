//  GameViewController.swift
//  Icosahedron
//
//  Created by Ralph Admin on 10/7/18.
//  Copyright © 2018 IYPC Software. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController
{
    var primaryScene: SCNScene!
    var scnView: SCNView?  // Changed from SCNView! to SCNView? to fix implicitly unwrapped optional
    
    var octahedronNode: SCNNode!
    var tetrahedronNode_1: SCNNode!
    var tetrahedronNode_2: SCNNode!
    
    var redMaterial: SCNMaterial!
    var darkGrayMaterial: SCNMaterial!
    var blueMaterial: SCNMaterial!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("viewDidLoad")
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
        
        scnView = self.view as? SCNView
        guard let scnView = scnView else {
            fatalError("Expected SCNView")
            //  a fatal error found in GameViewController at line 50. Expected SCNView
        }
        
        scnView.scene = primaryScene
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.clear
        scnView.debugOptions = .showWireframe
        
        //        generateTetrahedron()
        generateOctahedron()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    
    func generateTetrahedron()
    {
        let vertices: [SCNVector3] = [
            SCNVector3(sqrt(8/9), 0, -1/3),
            SCNVector3(-sqrt(2/9), sqrt(2/3), -1/3.0),
            SCNVector3(-sqrt(2/9), -sqrt(2/3), -1/3),
            SCNVector3( 0, 0, 1)
        ]
        
        print("tetrahedron edge length: \(String(describing: sqrt(8/3.0)))")
        
        let source = SCNGeometrySource(vertices: vertices)
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 0, 3,
            3, 0, 1,
            1, 2, 3
        ]
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [redMaterial]
        tetrahedronNode_1 = SCNNode(geometry: geometry)
        tetrahedronNode_1.position = SCNVector3Make(-1.5, 0, 0)
        tetrahedronNode_1.position = SCNVector3Zero
        primaryScene.rootNode.addChildNode(tetrahedronNode_1)
    }
    
    func generateOctahedron()
    {
        let vertices: [SCNVector3] = [
            SCNVector3(1, 0, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(0, 1, 0),
            SCNVector3(0, -1, 0),
            SCNVector3(0, 0, 1),
            SCNVector3(0, 0, -1)
        ]
        
        let indices: [UInt16] = [
            0, 2, 4,
            2, 1, 4,
            1, 3, 4,
            3, 0, 4,
            2, 0, 5,
            1, 2, 5,
            3, 1, 5,
            0, 3, 5
        ]
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [blueMaterial]
        octahedronNode = SCNNode(geometry: geometry)
        primaryScene.rootNode.addChildNode(octahedronNode)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer)
    {
        // Implementation for tap handling, if needed
    }
    
    override var shouldAutorotate: Bool { return true }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone { return .landscapeRight }
        else if UIDevice.current.userInterfaceIdiom == .pad { return .landscapeRight }
        else { return .all }
    }
}
