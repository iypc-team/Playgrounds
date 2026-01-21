//
//  GameViewController.swift
//  Icosahedron-2
//
//  Fixed by Code GPT 🧠 on 01/21/2026
//

import UIKit
import SceneKit
import SwiftUI

class GameViewController: UIViewController {
    
    // MARK: - Scene Properties
    private var primaryScene = SCNScene()
    private var scnView: SCNView!
    private var geometryGenerator = GeometryGenerator()
    private var currentNode: SCNNode?
    private var isWireframe = false
    
    // MARK: - Lifecycle
    override func loadView() {
        view = SCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupCamera()
        setupGestures()
        
        // Load initial geometry (fallback default)
        loadPolyhedron(type: .dodecahedron, wireframe: false)
    }
    
    // MARK: - Scene Setup
    private func setupScene() {
        guard let scnView = view as? SCNView else {
            fatalError("Expected SCNView")
        }
        self.scnView = scnView
        
        scnView.scene = primaryScene
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = .black
    }
    
    private func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 6)
        primaryScene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Tap Handling
    @objc private func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        guard let scnView = gestureRecognize.view as? SCNView else { return }
        let tapPoint = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(tapPoint, options: [:])
        
        if let result = hitResults.first {
            highlight(material: result.node.geometry?.firstMaterial)
        } else {
            toggleWireframeMode()
        }
    }
    
    // MARK: - Highlight Effect
    private func highlight(material: SCNMaterial?) {
        guard let material = material else { return }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        material.emission.contents = UIColor.red
        
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            material.emission.contents = UIColor.black
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }
    
    // MARK: - Wireframe Toggle
    private func toggleWireframeMode() {
        isWireframe.toggle()
        guard let geometry = currentNode?.geometry else { return }
        geometry.firstMaterial?.fillMode = isWireframe ? .lines : .fill
        
        let mode = isWireframe ? "Wireframe" : "Solid"
        print("🔄 Toggled to \(mode) mode.")
    }
}

// MARK: - SwiftUI Integration
extension GameViewController {
    /// Loads a new polyhedron shape into the SceneKit view.
    func loadPolyhedron(type: PlatonicSolid, wireframe: Bool) {
        // Defensive check: ensure SceneKit view is initialized
        guard scnView != nil else { return }
        
        // Remove old shape if present
        currentNode?.removeFromParentNode()
        
        // Create new solid using GeometryGenerator
        let node = geometryGenerator.generateSolid(type, wireframe: wireframe)
        
        // Add to the scene
        primaryScene.rootNode.addChildNode(node)
        currentNode = node
        
        // Update internal state
        isWireframe = wireframe
    }
}

// MARK: - Rotation Control
extension GameViewController {
    /// Enables or disables continuous rotation of the current polyhedron.
    func setRotation(enabled: Bool) {
        guard let node = currentNode else { return }
        
        node.removeAllActions()
        if enabled {
            let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8))
            node.runAction(rotateAction)
        }
    }
}
