//
// SceneConfiguration.swift
//

import SceneKit
import UIKit

struct SceneConfiguration {
    
    struct LightConfig {
        let type: SCNLight.LightType
        let color: UIColor
        let intensity: CGFloat?
        let castsShadow: Bool
        let attenuationEndDistance: CGFloat?
        let position: SCNVector3
    }
    
    struct PlaneConfig {
        let width: CGFloat = 3.0
        let height: CGFloat = 2.2
        let position = SCNVector3(x: 0, y: -2.55, z: 0)
        let rotationAngle: CGFloat = .pi / 2
        let materialColor: UIColor = .clear
        let isDoubleSided = true
        let fresnelExponent: CGFloat = 4
    }
    
    struct CameraConfig {
        let position = SCNVector3(x: 0, y: 0, z: 20)
        let lookAt = SCNVector3(0, 0, 0)
        let automaticallyAdjustsZRange = true
    }
    
    let camera = CameraConfig()
    
    let plane = PlaneConfig()
    
    let ambientLights: [LightConfig] = [
        LightConfig(
            type: .ambient,
            color: .clear,
            intensity: nil,
            castsShadow: false,
            attenuationEndDistance: nil,
            position: SCNVector3(x: 0, y: 0, z: 100)
        ),
        
        LightConfig(
            type: .ambient,
            color: .clear,
            intensity: nil,
            castsShadow: false,
            attenuationEndDistance: nil,
            position: SCNVector3(x: 0, y: 0, z: -100)
        )
    ]
    
    let engineLights: [LightConfig] = [
        LightConfig(
            type: .omni,
            color: .green,
            intensity: 10000,
            castsShadow: false,
            attenuationEndDistance: 4,
            position: SCNVector3(x: 0, y: -2, z: 0)
        ),
        
        LightConfig(
            type: .omni,
            color: .green,
            intensity: 10000,
            castsShadow: false,
            attenuationEndDistance: 4,
            position: SCNVector3(x: 0, y: 1.5, z: 0)
        )
    ]
    
    let cabinLight = LightConfig(
        type: .omni,
        color: .red,
        intensity: 10000,
        castsShadow: false,
        attenuationEndDistance: 4,
        position: SCNVector3(x: 0, y: -5.0, z: 0)
    )
}

