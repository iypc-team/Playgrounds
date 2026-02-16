//  AirplaneModel.swift
//
//  

import RealityFoundation
import RealityKit
import Foundation
import Combine

/// Configuration for airplane model loading.
struct AirplaneModelConfig {
    var airplaneScale: Float = 5.0
}

struct AirplaneModel {
    let entity: ModelEntity
    
    static func load(config: AirplaneModelConfig = AirplaneModelConfig()) async throws -> AirplaneModel {
        let loadRequest = await ModelEntity.loadModelAsync(named: "Airplane")
        
        return try await withCheckedThrowingContinuation { continuation in
            loadRequest.subscribe(Subscribers.Sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("❌ Failed to load airplane model: \(error)")
                        continuation.resume(throwing: error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { modelEntity in
                    Task {
                        await MainActor.run {
                            print("Loaded airplane model: \(modelEntity)")
                            print("Model mesh: \(String(describing: modelEntity.model?.mesh))")
                            print("Model materials: \(String(describing: modelEntity.model?.materials))")
                            
                            modelEntity.scale = SIMD3<Float>(repeating: config.airplaneScale)
                            print("Applied airplaneScale: \(config.airplaneScale), resulting scale: \(modelEntity.scale)")
                            
                            // Removed cone generation to avoid mesh API errors
                            continuation.resume(returning: AirplaneModel(entity: modelEntity))
                        }
                    }
                }
            ))
        }
    }
}
