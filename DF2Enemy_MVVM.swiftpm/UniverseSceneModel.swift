//  UniverseSceneModel.swift
//  DF2Enemy_MVVM.swiftpm
//

import SceneKit

struct UniverseSceneModel {
    let radius: Double
    let imageName: String
    let lightPositions: [SCNVector3]
    
    init(radius: Double = 2048.0 * 4, imageName: String = "JWST_2.png", lightPositions: [SCNVector3] = [
        SCNVector3(x: 0, y: 0, z: 100),
        SCNVector3(x: 0, y: 0, z: -100)
    ]) {
        self.radius = radius
        self.imageName = imageName
        self.lightPositions = lightPositions
    }
}
