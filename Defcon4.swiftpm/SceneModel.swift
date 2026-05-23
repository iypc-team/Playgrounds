// SceneModel.swift
// 

import SceneKit

struct SceneModel {
    var sceneName: String = "newFighter.scn"
    var enemyName: String = "smooth_ship.scn"   // was: enenyName (typo fixed)
    
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 60)
    
    // Fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    // Radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // Lighting
    var lightIntensity: CGFloat = 200
    var omniLightIntensity: CGFloat = 5000
    
    var cabinLightColor: UIColor = UIColor.red
    var cabinLightIntensity: CGFloat = 3000
    
    var engineLightColor: UIColor = UIColor.green
    var engineLightIntensity: CGFloat = 3000
}
