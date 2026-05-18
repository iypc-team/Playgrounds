// RedTargetSphere.swift
// 

import SceneKit

class RedTargetSphere {
    
    static func create() -> SCNNode {
        // Geometry
        let sphere = SCNSphere(radius: 2.0)
        
        // Material (Red)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.specular.contents = UIColor.white
        material.shininess = 0.6
        sphere.materials = [material]
        
        // Node
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 10, 0)
        node.name = "RedTargetSphere"
        
        // Kinematic Physics Body
        let body = SCNPhysicsBody(type: .kinematic, shape: nil)
        body.categoryBitMask = SceneViewModel.PhysicsCategory.target
        body.collisionBitMask = SceneViewModel.PhysicsCategory.radar | SceneViewModel.PhysicsCategory.fighter
        body.contactTestBitMask = SceneViewModel.PhysicsCategory.radar | SceneViewModel.PhysicsCategory.fighter
        node.physicsBody = body
        
        return node
    }
}
