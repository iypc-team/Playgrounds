// RedTargetSphere.swift
// 

import SceneKit

class RedTargetSphere {
    
    static func create() -> SCNNode {
        // Geometry
        let sphere = SCNSphere(radius: 5.0)
        
        // Material (Red)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.specular.contents = UIColor.white
        material.shininess = 0.6
        sphere.materials = [material]
        
        // Node
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 30, 0)
        node.name = "RedTargetSphere"
        
        // Kinematic physics — collisionBitMask is not set because kinematic bodies
        // do not participate in collision response; contactTestBitMask drives callbacks.
        let body = SCNPhysicsBody(type: .kinematic, shape: nil)
        body.categoryBitMask    = SceneViewModel.PhysicsCategory.target
        body.contactTestBitMask = SceneViewModel.PhysicsCategory.radar | SceneViewModel.PhysicsCategory.fighter
        node.physicsBody = body
        
        return node
    }
}
