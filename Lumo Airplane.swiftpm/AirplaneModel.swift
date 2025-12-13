//  Value of type 'LoadRequest<ModelEntity>' has no member 'value'
// cannot convert valur of type 'LoadRequest<ModelEntity> to expected argument type 'ModelEntity'

import RealityKit
import Combine

struct AirplaneModel {
    let entity: ModelEntity
    let rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)
    
    static func load() async throws -> AirplaneModel {
        let loadRequest = await ModelEntity.loadModelAsync(named: "Airplane")
        
        return try await withCheckedThrowingContinuation { continuation in
            loadRequest.subscribe(Subscribers.Sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { modelEntity in
                    Task {
                        await MainActor.run {
                            modelEntity.scale = SIMD3<Float>(repeating: 3.0)
                        }
                        continuation.resume(returning: AirplaneModel(entity: modelEntity))
                    }
                }
            ))
        }
    }
}
