// 
// 

// AirplaneViewModel.swift

import Foundation
import RealityKit

class AirplaneViewModel: ObservableObject {
    @Published var airplaneModel: AirplaneModel
    
    var airplaneEntity: ModelEntity?
    
    init(airplaneModel: AirplaneModel = .defaultAirplane) {
        self.airplaneModel = airplaneModel
        loadModel()
    }
    
    func loadModel() {
        // Load the USDZ model
        guard let entity = try? ModelEntity.load(named: airplaneModel.modelName) else {
            fatalError("Unable to load \(airplaneModel.modelName)")
        }
        entity.scale = SIMD3(repeating: airplaneModel.scale)
        entity.position = airplaneModel.position
        airplaneEntity = entity as? ModelEntity
    }
    
    func moveModel(to newPosition: SIMD3<Float>) {
        airplaneEntity?.position = newPosition
        airplaneModel.position = newPosition
    }
    
    func scaleModel(_ newScale: Float) {
        airplaneEntity?.scale = SIMD3(repeating: newScale)
        airplaneModel.scale = newScale
    }
}





