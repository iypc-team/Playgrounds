// 
// 

import SceneKit
import Foundation

// Updated SceneModel.swift
class SceneModel: ObservableObject {
    var sceneName: String = "fighter.scn"
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 50)
    
    // New properties for fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    // New property for radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // properties for lighting
    var lightIntensity: CGFloat = 200
    var omniLightIntensity: CGFloat = 3000
    
    // Add more properties as needed
}
