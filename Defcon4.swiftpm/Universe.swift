// Universe.swift
// 

import SceneKit

/// A large universe background sphere with galaxy texture
class Universe {
    
    static let radius: CGFloat = 2048
    
    /// Creates and returns a configured universe sphere node
    static func createNode() -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        
        let material = SCNMaterial()
        
        // Use Galaxy.jpg as the diffuse texture
        material.diffuse.contents = "Galaxy.jpg"
        
        // Optional enhancements for better look
        material.specular.contents = UIColor.white.withAlphaComponent(0.2)
        material.emission.contents = UIColor.white.withAlphaComponent(0.15)
        material.lightingModel = .constant     // No real shading (good for skybox)
        
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.name = "Universe"
        
        // Flip the sphere so the texture is visible from inside
        node.scale = SCNVector3(1, 1, -1)
        
        // Center at world origin
        node.position = SCNVector3Zero
        
        return node
    }
}
