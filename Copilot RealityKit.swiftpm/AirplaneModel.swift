// 
// 

// AirplaneModel.swift

import Foundation

struct AirplaneModel {
    var modelName: String
    var scale: Float
    var position: SIMD3<Float>
    
    static let defaultAirplane = AirplaneModel(modelName: "Airplane", scale: 1.0, position: [0, 0, 0])
}



//
