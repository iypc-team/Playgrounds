//// Universe.swift
//
//import SceneKit
//
///// A large universe background sphere optimized for mobile performance
///// Galaxy texture target: 2048 × 1024
//class Universe {
//    
//    static let radius: CGFloat = 2048
//    
//    /// Creates and returns a configured universe sphere node
//    static func createNode() -> SCNNode {
//        let sphere = SCNSphere(radius: radius)
//        
//        let material = SCNMaterial()
//        
//        let galaxyImage = UIImage(named: "Galaxy")
//        assert(galaxyImage != nil, "⚠️ Galaxy image is missing from Assets.xcassets.")
//        material.diffuse.contents = galaxyImage
//        
//        material.diffuse.wrapS = .repeat
//        material.diffuse.wrapT = .repeat
//        material.diffuse.mipFilter           = .nearest
//        material.diffuse.minificationFilter  = .linear
//        material.diffuse.magnificationFilter = .nearest
//        
//        material.diffuse.intensity = 1.0
//        material.specular.contents = UIColor.black
//        material.emission.contents = UIColor.black
//        material.lightingModel = .constant
//        material.isDoubleSided = true
//        
//        sphere.materials = [material]
//        
//        let node = SCNNode(geometry: sphere)
//        node.name     = "Universe"
//        node.scale    = SCNVector3(1, 1, -1) // Correct inside view
//        node.position = SCNVector3Zero
//        
//        return node
//    }
//}
