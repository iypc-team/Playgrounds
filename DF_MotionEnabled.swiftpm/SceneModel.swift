// SceneModel.swift
// Defines data structures for scene configuration.
//  

import SwiftUI
import SceneKit

class SceneModel {
    // Available ship models for configuration
    static let availableShipNames = [
        "fighter",
        "newFighter",
        "fighterPBR",
        "smooth_ship",
        "airplane",
        "Y-Up-fighter.scn"
    ]
    
    // Configurable ship name
    var shipName: String
    
    /// Initializes the scene model with a ship name.
    /// - Parameter shipName: The name of the ship model to load (e.g., "fighter").
    init(shipName: String) {
        self.shipName = shipName  // Use the passed shipName instead of hardcoding
    }
    
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
        let position: SCNVector3 = SCNVector3Make(0, -2.55, 0)
        let rotationAngle: CGFloat = CGFloat(GLKMathDegreesToRadians(90.0))
        let materialColor: UIColor = .clear
        let isDoubleSided: Bool = true
        let fresnelExponent: CGFloat = .infinity
    }
    
    struct CameraConfig {
        let position: SCNVector3 = SCNVector3(x: 0, y: 0, z: 20)
        let lookAt: SCNVector3 = SCNVector3(0, 0, 0)
        let automaticallyAdjustsZRange: Bool = true
    }
    
    let camera = CameraConfig()
    let plane = PlaneConfig()
    let ambientLights: [LightConfig] = [
        LightConfig(type: .ambient, color: .clear, intensity: nil, castsShadow: false, attenuationEndDistance: nil, position: SCNVector3(x: 0, y: 0, z: 100)),
        LightConfig(type: .ambient, color: .clear, intensity: nil, castsShadow: false, attenuationEndDistance: nil, position: SCNVector3(x: 0, y: 0, z: -100))
    ]
    let engineLights: [LightConfig] = [
        LightConfig(type: .omni, color: .green, intensity: 10000, castsShadow: false, attenuationEndDistance: 4, position: SCNVector3(x: 0, y: -2, z: 0)),
        LightConfig(type: .omni, color: .green, intensity: 10000, castsShadow: false, attenuationEndDistance: 4, position: SCNVector3(x: 0, y: 1.5, z: 0))
    ]
    let cabinLight = LightConfig(type: .omni, color: .red, intensity: 10000, castsShadow: false, attenuationEndDistance: 4, position: SCNVector3(x: 0, y: -5.0, z: 0))
}
