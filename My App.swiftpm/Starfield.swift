////
////  Starfield.swift
////  3d Earth
////
////  Created by Ralph Admin on 10/19/18.
////  Copyright © 2018 IYPC Software. All rights reserved.
////
//
//import UIKit
//import QuartzCore
//import SceneKit
//
//class Starfield: NSObject
//{
//    override init()
//    {
//        super.init()
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    func addStarfield(scene: SCNScene)
//    {
//        let primaryScene = scene
//        let starfieldGeometryShape = SCNSphere(radius: 256)
//        starfieldGeometryShape.isGeodesic = true
//        let stars = SCNParticleSystem(named: "starParticles.scnp", inDirectory: nil)
//        stars?.orientationMode = SCNParticleOrientationMode.billboardYAligned
//        stars?.birthRate = 2500
//        stars?.emitterShape = starfieldGeometryShape
//        stars?.particleVelocity = 0.0
//        primaryScene.rootNode.addParticleSystem(stars!)
//    }
//}
