// Universe.swift
// 

import SceneKit

/// A large universe background sphere with galaxy texture.
class Universe {
    
    static let radius: CGFloat = 2048
    
    /// Creates and returns a configured universe sphere node.
    static func createNode() -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        
        let material = SCNMaterial()
        material.diffuse.contents = "Galaxy.jpg"
        // .constant lighting model bypasses all light interaction —
        // specular has no effect here and has been removed.
        material.emission.contents = UIColor.white.withAlphaComponent(0.15)
        material.lightingModel = .constant  // No shading — correct for a skybox
        
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.name = "Universe"
        // Flip Z-scale so the texture faces inward (visible from inside the sphere)
        node.scale = SCNVector3(1, 1, -1)
        node.position = SCNVector3Zero
        
        return node
    }
}
