//  AirplaneModel.swift
//  
//  

import RealityFoundation
import RealityKit
import Foundation
import Combine

/// Configuration for airplane model loading.
struct AirplaneModelConfig {
    var airplaneScale: Float = 9.5  // default 5.0
}

struct AirplaneModel {
    let entity: ModelEntity
    
    static func load(config: AirplaneModelConfig = AirplaneModelConfig()) async throws -> AirplaneModel {
        let loadRequest = await Entity.loadModelAsync(named: "Airplane")
        
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
                receiveValue: { entity in
                    Task {
                        await MainActor.run {
                            print("Loaded airplane model: \(entity)")
                            if let modelEntity = entity as? ModelEntity {
                                print("Model mesh: \(String(describing: modelEntity.model?.mesh))")
                                print("Model materials: \(String(describing: modelEntity.model?.materials))")
                                
                                modelEntity.transform.scale = SIMD3<Float>(repeating: config.airplaneScale)
                                print("Applied airplaneScale: \(config.airplaneScale), resulting scale: \(modelEntity.transform.scale)")
                                
                                continuation.resume(returning: AirplaneModel(entity: modelEntity))
                            } else {
                                continuation.resume(throwing: NSError(domain: "LoadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Loaded entity is not a ModelEntity"]))
                            }
                        }
                    }
                }
            ))
        }
    }
}
