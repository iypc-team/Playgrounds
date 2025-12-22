// Updated SceneModel.swift
import SceneKit
import Foundation

class SceneModel: ObservableObject {
    var sceneName: String = "fighter.scn"
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 30)
    var lightIntensity: CGFloat = 100
    
    // New properties for fighter node configuration
    var fighterScale: SCNVector3 = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
    
    var omniLightIntensity: CGFloat = 3000
    
    // New property for radar position
    var radarPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // Add more properties as needed
}
