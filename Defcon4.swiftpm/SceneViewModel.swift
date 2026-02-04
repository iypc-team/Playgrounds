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
                fighterRotationAction = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0, 0, 1), duration: 20)
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
        
        // Setup radar node
        let radarNode = SCNNode()
        radarNode.position = sceneModel.radarPosition  // Fix: Assign position from model
        radarNode.geometry = SCNCone(topRadius: 1.0, bottomRadius: 256, height: 1024)
        radarNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        // Set up physics body for radarNode as kinematic
        radarNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: radarNode.geometry!, options: nil))
        radarNode.physicsBody?.categoryBitMask = 1 << 0  // Radar category
        radarNode.physicsBody?.contactTestBitMask = 1 << 1  // Target category
        scene.rootNode.addChildNode(radarNode)
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
    
    func startFighterRotation() {
        guard let node = fighterNode, let action = fighterRotationAction, !isFighterRotating else { return }
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
            // Add your custom logic here, e.g., trigger an action, update UI, etc.
        }
    }
    
    // SCNPhysicsContactDelegate method to detect end of contact
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        // Check if radarNode and targetNode (fighterNode) are no longer in contact
        if (contact.nodeA == radarNode && contact.nodeB == fighterNode) ||
            (contact.nodeA == fighterNode && contact.nodeB == radarNode) {
            print("Radar node is no longer in contact with target node!")
            // Add your custom logic here, e.g., reset state, update UI, etc.
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
