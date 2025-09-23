////
////  Weapons.swift
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
//class Weapons: NSObject
//{
//    let game = GameViewController()
//    
//    var emitterNode: SCNNode!
//    var photonTorpedoNode: SCNNode!
//    var phaserNode: SCNNode!
//
//    override init()
//    {
//        super.init()
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    
//    
//    func addEmitterNode(attachToNode: SCNNode?)
//    {
//        var colliderArray = [SCNNode]()
//        let node = attachToNode
//        colliderArray.append(node!)
//
//        let emitterGeometry = node?.geometry!
//        emitterGeometry?.firstMaterial?.lightingModel = .constant
//        emitterGeometry!.firstMaterial?.diffuse.contents = UIColor.black
//        print("emitterGunGeometry: \(String(describing: emitterGeometry))")
//        
//        emitterNode = SCNNode(geometry: emitterGeometry)
//        emitterNode.name = "engineEmitter"
//        
//        let engineEmissionParticle = SCNParticleSystem(named: "defaultReactor.scnp", inDirectory: nil)!
//        engineEmissionParticle.colliderNodes = colliderArray
//        engineEmissionParticle.particleBounce = 1.0
//        engineEmissionParticle.acceleration = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
//        engineEmissionParticle.birthRate = 200
//        engineEmissionParticle.birthDirection = .constant
//        engineEmissionParticle.birthLocation = .surface
//        engineEmissionParticle.emitterShape = emitterGeometry
//        
//        engineEmissionParticle.isAffectedByGravity = false
//        engineEmissionParticle.isAffectedByPhysicsFields = true
//        engineEmissionParticle.isLocal = true
//        engineEmissionParticle.isLightingEnabled = true
//        engineEmissionParticle.isBlackPassEnabled = true
//        engineEmissionParticle.loops = true
//        
//        engineEmissionParticle.particleDiesOnCollision = true
//        engineEmissionParticle.particleColor = UIColor.cyan
//        engineEmissionParticle.particleIntensity = 2.0
//        engineEmissionParticle.particleLifeSpan = 1.5
//        engineEmissionParticle.particleLifeSpanVariation = 0.5
//        engineEmissionParticle.particleDiesOnCollision = true
//        engineEmissionParticle.particleSize = 0.03125
//
//        engineEmissionParticle.spreadingAngle = 0.0
//        engineEmissionParticle.speedFactor = 5.0
//        engineEmissionParticle.stretchFactor = 2.5
//        
////        showParticleSystemValues(particleSystem: engineEmissionParticle)
//        
//        emitterNode.addParticleSystem(engineEmissionParticle)
//        
////        emitterNode.transform = SCNMatrix4Rotate(emitterNode.transform, Float.pi, 1, 0, 0)
//        node?.addChildNode(emitterNode)
//    }
//    
//    
//    func addPhaserNode(attachToNode: SCNNode?)
//    {
//        let node = attachToNode
//
//        let phaserTubeGeometry = SCNCylinder(radius: 0.01, height: 0.01)
//        phaserTubeGeometry.firstMaterial?.diffuse.contents = UIColor.clear
//        let phaserTubeNode = SCNNode(geometry: phaserTubeGeometry)
//        
//        let phaserGunGeometery = SCNCylinder(radius: 0.5, height: 2)
//        phaserGunGeometery.firstMaterial?.diffuse.contents = UIColor.blue
//        
//        phaserNode = SCNNode(geometry: phaserGunGeometery)
//        phaserNode.name = "phaser"
//        phaserNode.position = SCNVector3Make(-4.5, 0, 0.125)
//        phaserNode.addChildNode(phaserTubeNode)
//        
//        let bottom = SCNCylinder(radius: 0.75, height: 0.2)
//        bottom.firstMaterial?.diffuse.contents = UIColor.blue
//        let bottomNode = SCNNode(geometry: bottom)
//        bottomNode.position = SCNVector3Make(0, -1.25, 0)
//        phaserNode.addChildNode(bottomNode)
//        
//        let phaserParticle = SCNParticleSystem(named: "defaultReactor.scnp", inDirectory: nil)!
//        phaserParticle.acceleration = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
//        phaserParticle.birthRate = 25
//        phaserParticle.birthDirection = .constant
//        phaserParticle.birthLocation = .surface
//        phaserParticle.emitterShape = phaserTubeGeometry
//        
//        phaserParticle.isAffectedByGravity = false
//        phaserParticle.isAffectedByPhysicsFields = false
//        phaserParticle.isLocal = true
//        phaserParticle.isLightingEnabled = true
//        phaserParticle.isBlackPassEnabled = true
//        phaserParticle.loops = true
//        
//        phaserParticle.particleDiesOnCollision = true
//        phaserParticle.particleColor = UIColor.cyan
//        phaserParticle.particleIntensity = 2.0
//        phaserParticle.particleLifeSpan = 20.0
//        phaserParticle.particleSize = 0.03125
//
//        phaserParticle.spreadingAngle = 0.0
//        phaserParticle.stretchFactor = 2.5
//        
////        showParticleSystemValues(particleSystem: phaserParticle)
//
//        phaserTubeNode.addParticleSystem(phaserParticle)
//        
//        phaserNode.transform = SCNMatrix4Rotate(phaserNode.transform, Float.pi, 1, 0, 0)
//        
//        node?.addChildNode(phaserNode)
//
//    }
//    
//    
//    func addPhotonTorpedoNode(attachToNode: SCNNode?)
//    {
//        let node = attachToNode
//        
//        let photonTubeGeometry = SCNCylinder(radius: 0.01, height: 0.01)
//        photonTubeGeometry.firstMaterial?.diffuse.contents = UIColor.clear
//        let phaserTubeNode = SCNNode(geometry: photonTubeGeometry)
//        
//        let photonGunGeometery = SCNCylinder(radius: 0.5, height: 2)
//        photonGunGeometery.firstMaterial?.diffuse.contents = UIColor.red
//        
//        photonTorpedoNode = SCNNode(geometry: photonGunGeometery)
//        photonTorpedoNode.name = "photonTorpedo"
//        photonTorpedoNode.position = SCNVector3Make(4.5, 0, 0.125)
//        photonTorpedoNode.addChildNode(phaserTubeNode)
//        
//        let bottom = SCNCylinder(radius: 0.75, height: 0.2)
//        bottom.firstMaterial?.diffuse.contents = UIColor.red
//        let bottomNode = SCNNode(geometry: bottom)
//        bottomNode.position = phaserTubeNode.position
//        bottomNode.position.y -= 1.25
//        photonTorpedoNode.addChildNode(bottomNode)
//        
//        
//        let photonTorpedoParticle = SCNParticleSystem(named: "defaultReactor.scnp", inDirectory: nil)!
//        photonTorpedoParticle.birthRate = 1
//        photonTorpedoParticle.emissionDuration = 1.0
//        photonTorpedoParticle.idleDuration = 1.0
//        photonTorpedoParticle.acceleration = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
//        photonTorpedoParticle.birthDirection = .constant
//        photonTorpedoParticle.birthLocation = .surface
//        photonTorpedoParticle.emitterShape = photonTubeGeometry
//        
//        photonTorpedoParticle.isAffectedByGravity = false
//        photonTorpedoParticle.isAffectedByPhysicsFields = false
//        photonTorpedoParticle.isLocal = true
//        photonTorpedoParticle.isLightingEnabled = true
//        photonTorpedoParticle.isBlackPassEnabled = true
//
//        photonTorpedoParticle.loops = true
//        photonTorpedoParticle.particleDiesOnCollision = true
//        photonTorpedoParticle.particleColor = UIColor.yellow
//        photonTorpedoParticle.particleIntensity = 2.0
//        photonTorpedoParticle.particleLifeSpan = 20.0
//        photonTorpedoParticle.spreadingAngle = 0.0
//        photonTorpedoParticle.speedFactor = 2.0
//
////        showParticleSystemValues(particleSystem: photonTorpedoParticle)
//        
//        phaserTubeNode.addParticleSystem(photonTorpedoParticle)
//        
//        photonTorpedoNode.transform = SCNMatrix4Rotate(photonTorpedoNode.transform, Float.pi, 1, 0, 0)
//        node?.addChildNode(photonTorpedoNode)
//        
//    }
//    
//    
//    func showParticleSystemValues(particleSystem: SCNParticleSystem)
//    {
//        print("\nacceleration: \(String(describing: particleSystem.acceleration))")
//        print("birthRate: \(String(describing: particleSystem.birthRate))")
//        print("birthDirection: \(String(describing: particleSystem.birthDirection.rawValue))")
//        print("birthLocation: \(String(describing: particleSystem.birthLocation.rawValue))")
//        print("birthRateVariation: \(String(describing: particleSystem.birthRateVariation))")
//        print("emissionDuration: \(String(describing: particleSystem.emissionDuration))")
//        print("emittingDirection: \(String(describing: particleSystem.emittingDirection))")
//        print("emissionDurationVariation: \(String(describing: particleSystem.emissionDurationVariation))")
//        print("emitterShape: \(String(describing: particleSystem.emitterShape.debugDescription))")
//        print("idleDuration: \(String(describing: particleSystem.idleDuration))")
//        print("idleDurationVariation: \(String(describing: particleSystem.idleDurationVariation))")
//        print("isLightingEnabled: \(String(describing: particleSystem.isLightingEnabled))")
//        
//        print("\norientationDirection: \(String(describing: particleSystem.orientationDirection))")
//        print("orientationMode: \(String(describing: particleSystem.orientationMode))")
//
//        print("\nparticleIntensity: \(String(describing: particleSystem.particleIntensity))")
//        print("particleMass: \(String(describing: particleSystem.particleMass))")
//        print("particleSize: \(String(describing: particleSystem.particleSize))")
//        print("particleAngle: \(String(describing: particleSystem.particleAngle))")
//        print("particleColor: \(String(describing: particleSystem.particleColor))")
//        print("particleImage: \(String(describing: particleSystem.particleImage))")
//        print("particleLifeSpan: \(String(describing: particleSystem.particleLifeSpan))")
//        print("particleVelocity: \(String(describing: particleSystem.particleVelocity))")
//        print("particleIntensity: \(String(describing: particleSystem.particleIntensity))")
//        print("particleSize: \(String(describing: particleSystem.particleSize))")
//        print("\nspeedFactor: \(String(describing: particleSystem.speedFactor))")
//        print("stretchFactor: \(String(describing: particleSystem.stretchFactor))")
//        print("warmupDuration: \(String(describing: particleSystem.warmupDuration))")
//        
//        print()
//        
//    }
//    
//}
//
