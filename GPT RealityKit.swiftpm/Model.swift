// 
// 

import RealityKit
import Combine

final class AirplaneModel {
    private let modelName = "Airplane.usdz"
    
    // Loads RealityKit ModelEntity for logic
    func loadModelEntity() -> AnyPublisher<ModelEntity, Error> {
        ModelEntity.loadAsync(named: modelName)
            .map { entity in
                entity.name = "Airplane"
                return entity
            }
            .eraseToAnyPublisher()
    }
}

