// 
// 

import SceneKit
import Foundation

// Updated SceneModel.swift
class SceneModel: ObservableObject {
    var sceneName: String = "newFighter.scn"
    var enenyName: String = "smooth_ship.scn"
    
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 20)
    
    // New properties for fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    // property for radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // properties for lighting
    var lightIntensity: CGFloat = 200
    var omniLightIntensity: CGFloat = 5000
    var cabinLightColor: UIColor = UIColor.red
    var engineLightColor: UIColor = UIColor.green
    
    // Add more properties as needed
}

