// EnemyShipModel: Represents the ship data
// 

//import SwiftUI
//import SceneKit
//
//struct EnemyShipModel {
//    var position: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
//    var rotation: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
//}

import SwiftUI
import SceneKit

struct EnemyShipModel {
    var position: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    var rotation: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // Adding orientation as a quaternion
    var orientation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    
    mutating func updateOrientation(angle: Float, axis: SIMD3<Float>) {
        orientation = simd_quatf(angle: angle, axis: axis)
    }
}
