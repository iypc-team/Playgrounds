//  SceneViewModel.swift
//  

import SwiftUI
import SceneKit
import Foundation

class SceneViewModel: NSObject, ObservableObject, SCNPhysicsContactDelegate {
    
    @Published var sceneModel: SceneModel
    @Published var selectedNode: SCNNode?
    @Published var scene: SCNScene
    @Published var isRotating: Bool = false
    @Published var isFighterRotating: Bool = false
    @Published var fighterNode: SCNNode?
    private var radarNode: SCNNode?
    private var rotationAction: SCNAction?
    private var fighterRotationAction: SCNAction?
    
    override init() {
        self.scene = SCNScene()  // Initialize scene first
        self.sceneModel = SceneModel()  // Initialize SceneModel first
        super.init()  // Call super.init() after initializing properties
        
        // Now proceed with loading the scene
        if let loadedScene = SCNScene(named: sceneModel.sceneName) {
            self.scene = loadedScene  // Update to loaded scene if available
            // Find and store the fighter node
            if let fighter = scene.rootNode.childNode(withName: "fighter", recursively: true) {
                self.fighterNode = fighter
                // Set up physics body for targetNode (fighterNode) as kinematic
                fighter.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: fighter, options: nil))
                fighter.physicsBody?.categoryBitMask = 1 << 1  // Target category
                fighter.physicsBody?.contactTestBitMask = 1 << 0  // Radar category
            }
        } else {
            print("loadedScene did not")
        }
        setupScene()  // Configure camera and lights
    }
    
    public func setupScene() {
        // Set physics world delegate
        scene.physicsWorld.contactDelegate = self
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = sceneModel.cameraPosition
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup radar node as child of fighterNode (if available)
        let radarNode = SCNNode()
        // Match geometry from SceneKitView
        radarNode.geometry = SCNCone(topRadius: 0.2, bottomRadius: 10.0, height: 1024)
        radarNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        radarNode.geometry?.firstMaterial?.transparency = 0.1  // Match transparency
        radarNode.geometry?.firstMaterial?.lightingModel = .constant  // Match lighting model
        // Match position from SceneKitView
        let radarOffset = ((radarNode.geometry!.boundingBox.max.y - radarNode.geometry!.boundingBox.min.y) / 2) + 8.0  // ~520
        radarNode.position = SCNVector3(0, -radarOffset, 0.25)
        
        // Set up physics body for radarNode as kinematic
        radarNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: radarNode.geometry!, options: nil))
        radarNode.physicsBody?.categoryBitMask = 1 << 0  // Radar category
        radarNode.physicsBody?.contactTestBitMask = 1 << 1  // Target category
        
        // Add as child of fighterNode if available, otherwise to root
        if let fighter = self.fighterNode {
            fighter.addChildNode(radarNode)
        } else {
            scene.rootNode.addChildNode(radarNode)
        }
        self.radarNode = radarNode  // Store reference
        
        // Prepare rotation action for later use
        rotationAction = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 2.0)
        
        // Setup lights
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        ambientLightNode.light!.intensity = sceneModel.lightIntensity
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func startRotation() {
        guard !isRotating, let action = rotationAction else { return }
        let repeatRotation = SCNAction.repeatForever(action)
        if let radarNode = self.radarNode {
            radarNode.runAction(repeatRotation)
            isRotating = true
        }
    }
    
    func stopRotation() {
        if let radarNode = self.radarNode {
            radarNode.removeAllActions()
            isRotating = false
        }
    }
    
    // Public methods to start and stop fighter (node) rotation
    func startFighterRotation() {
        guard let node = fighterNode, !isFighterRotating else { return }
        let action = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 20)
        let repeatAction = SCNAction.repeatForever(action)
        node.runAction(repeatAction)
        isFighterRotating = true
    }
    
    func stopFighterRotation() {
        if let node = fighterNode {
            node.removeAllActions()
            isFighterRotating = false
        }
    }
    
    // SCNPhysicsContactDelegate method to detect start of contact
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // Check if radarNode and targetNode (fighterNode) are in contact
        if (contact.nodeA == radarNode && contact.nodeB == fighterNode) ||
            (contact.nodeA == fighterNode && contact.nodeB == radarNode) {
            print("Radar node is in contact with target node!")
            // Print targetNode.position (assuming fighterNode is targetNode)
            if let targetNode = contact.nodeA == fighterNode ? contact.nodeA : contact.nodeB == fighterNode ? contact.nodeB : nil {
                print("targetNode.position: \(targetNode.position)")
            }
        }
    }
    
    // SCNPhysicsContactDelegate method to detect end of contact
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        // Check if radarNode and targetNode (fighterNode) are no longer in contact
        if (contact.nodeA == radarNode && contact.nodeB == fighterNode) ||
            (contact.nodeA == fighterNode && contact.nodeB == radarNode) {
            print("Radar node is no longer in contact with target node!")
        }
    }
    
    private func positionRadarNode(_ radarNode: SCNNode) {
        guard let geometry = radarNode.geometry else { 
            print("Radar node has no geometry.")
            return 
        }
        
        let boundingBox = geometry.boundingBox
        var length = boundingBox.max.y - boundingBox.min.y  // Operate on y-axis only
        length += length / 2.5
        
        sceneModel.radarPosition = SCNVector3(x: 0.0, y: length / 2.0, z: 0)
        print("sceneModel.radarPosition: \(sceneModel.radarPosition)")
    }
}
