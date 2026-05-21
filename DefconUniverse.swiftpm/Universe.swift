// Universe.swift
// 

import SceneKit

/// A large universe background sphere optimized for mobile performance
/// Galaxy texture target: 2048 × 1024
class Universe {
    
    static let radius: CGFloat = 2048
    
    /// Creates and returns a configured universe sphere node
    static func createNode() -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        
        let material = SCNMaterial()
        material.diffuse.contents = "Galaxy.jpg"
        
        // Sharp texture filtering — avoids blurry interpolation on the galaxy image
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        material.diffuse.mipFilter  = .nearest          // sharp mip transitions
        material.diffuse.minificationFilter  = .linear  // clean detail at distance
        material.diffuse.magnificationFilter = .nearest // crisp / sharp close-up pixels
        
        // Full diffuse intensity — no softening
        material.diffuse.intensity = 1.0
        
        // Remove specular and emission blur; keep constant lighting for performance
        material.specular.contents = UIColor.black
        material.emission.contents = UIColor.black
        material.lightingModel = .constant
        
        // Required for inside-sphere visibility
        material.isDoubleSided = true
        
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.name = "Universe"
        node.scale    = SCNVector3(1, 1, -1)    // Correct inside view
        node.position = SCNVector3Zero
        
        return node
    }
}
