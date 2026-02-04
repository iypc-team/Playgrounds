//  SceneModel.swift
// 

import SceneKit
//import Foundation

class SceneModel: ObservableObject {
    var sceneName: String = "newFighter.scn"
    var enenyName: String = "smooth_ship.scn"
    
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 25, z: 60)
    
    // New properties for fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    // property for radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // properties for lighting
    var lightIntensity: CGFloat = 200
    var omniLightIntensity: CGFloat = 5000
    
    var cabinLightColor: UIColor = UIColor.red
    var cabinLightIntensity: CGFloat = 3000
    
    var engineLightColor: UIColor = UIColor.green
    var engineLightIntensity: CGFloat = 3000
    
    // Add more properties as needed
}

