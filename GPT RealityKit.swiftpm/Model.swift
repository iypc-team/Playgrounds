// 
// 

import RealityKit
import Combine
import Dispatch

final class AirplaneModel {
    let modelName = "Airplane.usdz"
    
    func loadModelEntity() -> AnyPublisher<ModelEntity, Error> {
        return Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    // On iOS 16 you can use Entity.loadModel(named:in:) or Entity.load(named:in:)
                    let modelEntity = try ModelEntity.loadModel(named: self.modelName)
                    DispatchQueue.main.async {
                        promise(.success(modelEntity))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}



//
