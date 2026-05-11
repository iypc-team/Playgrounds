// ShieldFactory.swift
//

import SceneKit
import UIKit

enum ShieldFactory {
    
    // Creates a simple "ghost" SCNNode for shield effect.
    
    static func makeShieldNode() -> SCNNode {
        
        let sphere = SCNSphere(radius: 8)
        
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.black
        
        material.reflective.contents = UIColor(
            red: 0,
            green: 0.764,
            blue: 1,
            alpha: 1
        )
        
        material.reflective.intensity = 3
        
        material.transparent.contents = UIColor.black.withAlphaComponent(0.3)
        
        material.transparencyMode = .default
        
        material.fresnelExponent = 4
        
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        
        sphereNode.position = SCNVector3(0, 0, 0)
        
        sphereNode.opacity = 0
        
        return sphereNode
    }
}

