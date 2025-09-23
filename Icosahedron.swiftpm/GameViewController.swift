//
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
    var scnView: SCNView!
    
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
        tetrahedronNode_1.scale = SCNVector3Make(1, 1, 1)
        
        let pointGeometry = SCNSphere(radius: 0.25)
        pointGeometry.materials = [darkGrayMaterial]
        let pointNode = SCNNode(geometry: pointGeometry)
        pointNode.position = SCNVector3Make(-1.5, 2, 0)
        pointNode.position = tetrahedronNode_1.position
        pointNode.position.y += 1.5
        tetrahedronNode_1.addChildNode(pointNode)
        scnView.scene?.rootNode.addChildNode(tetrahedronNode_1)
        
        
        tetrahedronNode_2 = tetrahedronNode_1.copy() as? SCNNode
        tetrahedronNode_2.position = SCNVector3Make(1.5, 0, 0)
        tetrahedronNode_2.scale = SCNVector3Make(1, 1, 1)
        tetrahedronNode_2.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 1, z: 0, duration: 2)))

//        primaryScene.rootNode.addChildNode(tetrahedronNode_2)
        
    }
    
    func generateOctahedron()
    {
        let vertices: [SCNVector3] = [
            SCNVector3(0, 1, 0),
            SCNVector3(-0.5, 0, 0.5),
            SCNVector3(0.5, 0, 0.5),
            SCNVector3(0.5, 0, -0.5),
            SCNVector3(-0.5, 0, -0.5),
            SCNVector3(0, -1, 0),
            ]
        
        let source = SCNGeometrySource(vertices: vertices)
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 3, 0,
            3, 4, 0,
            4, 1, 0,
            1, 5, 2,
            2, 5, 3,
            3, 5, 4,
            4, 5, 1
        ]
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        octahedronNode = SCNNode(geometry: geometry)
        octahedronNode.geometry?.materials = [blueMaterial]
        octahedronNode.scale = SCNVector3Make(1, 1, 1)
        let pointGeometry = SCNSphere(radius: 0.5)
        pointGeometry.materials = [redMaterial]
        let pointNode = SCNNode(geometry: pointGeometry)
        pointNode.position = SCNVector3Make(-1.5, 2, 0)
        pointNode.position = octahedronNode.position
        pointNode.position.y += 1.5
        octahedronNode.addChildNode(pointNode)
        scnView.scene?.rootNode.addChildNode(octahedronNode)
        
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8))
        octahedronNode.runAction(rotateAction)
    }
    
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer)
    {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool { return true }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad { return .allButUpsideDown }
        else { return .all }
    }

}
