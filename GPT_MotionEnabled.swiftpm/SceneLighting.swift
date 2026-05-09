//
// SceneLighting.swift
//

import SceneKit

enum SceneLighting {
    
    static func makeLightNode(
        from config: SceneConfiguration.LightConfig
    ) -> SCNNode {
        
        let lightNode = SCNNode()
        
        lightNode.light = SCNLight()
        
        lightNode.light?.type = config.type
        
        lightNode.light?.color = config.color
        
        if let intensity = config.intensity {
            lightNode.light?.intensity = intensity
        }
        
        lightNode.light?.castsShadow = config.castsShadow
        
        if let attenuation = config.attenuationEndDistance {
            lightNode.light?.attenuationEndDistance = attenuation
        }
        
        lightNode.position = config.position
        
        return lightNode
    }
}

