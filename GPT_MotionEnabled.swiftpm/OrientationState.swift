//
// OrientationState.swift
//

import Foundation
import SceneKit

struct OrientationState {
    let orientation: SCNVector4
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    static let neutral = OrientationState(
        orientation: SCNVector4(0, 0, 0, 1),
        roll: 0,
        pitch: 0,
        yaw: 0
    )
}

