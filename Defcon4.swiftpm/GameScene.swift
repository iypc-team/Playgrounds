//  GameScene.swift
//  

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Define collision categories
    let radarCategory: UInt32 = 0x1 << 0
    let targetCategory: UInt32 = 0x1 << 1
    
    override func didMove(to view: SKView) {
        // Set the physics world's contact delegate
        physicsWorld.contactDelegate = self
        
        // Create the radar node
        let radarNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        radarNode.position = CGPoint(x: 100, y: 100)
        radarNode.physicsBody = SKPhysicsBody(rectangleOf: radarNode.size)
        radarNode.physicsBody?.categoryBitMask = radarCategory
        radarNode.physicsBody?.contactTestBitMask = targetCategory
        radarNode.physicsBody?.collisionBitMask = 0
        radarNode.physicsBody?.isDynamic = true
        addChild(radarNode)
        
        // Create the target node
        let targetNode = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        targetNode.position = CGPoint(x: 200, y: 200)
        targetNode.physicsBody = SKPhysicsBody(rectangleOf: targetNode.size)
        targetNode.physicsBody?.categoryBitMask = targetCategory
        targetNode.physicsBody?.contactTestBitMask = radarCategory
        targetNode.physicsBody?.collisionBitMask = 0
        targetNode.physicsBody?.isDynamic = true
        addChild(targetNode)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Identify radarNode and targetNode from the contact
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        if let radarNode = nodeA, let targetNode = nodeB {
            if contact.bodyA.categoryBitMask == radarCategory && contact.bodyB.categoryBitMask == targetCategory {
                print("Radar node made contact with target node!")
                print("Target node position: \(targetNode.position)")
            } else if contact.bodyA.categoryBitMask == targetCategory && contact.bodyB.categoryBitMask == radarCategory {
                print("Target node made contact with radar node!")
                print("Target node position: \(radarNode.position)")
            }
        }
    }
}

