//  Value of type 'LoadRequest<ModelEntity>' has no member 'value'
// cannot convert valur of type 'LoadRequest<ModelEntity> to expected argument type 'ModelEntity'

import SwiftUI
import RealityKit
import Combine   // Ensure Combine is imported
import simd

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
                        break  // Handled in receiveValue
                    }
                },
                receiveValue: { modelEntity in
                    // Optional: centre the model, set an initial scale, etc.
                    //                    modelEntity.scale = SIMD3<Float>(repeating: 0.5)
                    
                    continuation.resume(returning: AirplaneModel(entity: modelEntity))
                }
            ))
        }
    }
}
