//  AirplaneModel.swift
//
//  

import RealityKit
import Foundation
import Combine

/// Configuration for airplane model loading and cone generation.
struct AirplaneModelConfig {
    var airplaneScale: Float = 3.0
    var coneRadius: Float = 256.0  // Default radius
    var coneHeight: Float = 1024.0 // Default height
    var coneSegments: Int = 36
    
    var conePositionOffset: SIMD3<Float> {
        SIMD3<Float>(0.0, 0.0, coneHeight / 2.0 + 0.4)
    }
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
                        // Error logging and potential notifications
                        print("❌ Failed to load airplane model: \(error)")
                        
                        // Optional: Send error to remote logging (e.g., Firebase, Sentry).
                        // LoggerService.logError(error)
                        
                        // Provide optional UI feedback
                        DispatchQueue.main.async {
                            // UI-level actions on errors can be added here
                        }
                        //  Cannot find 'DispatchQueue' in scope
                        continuation.resume(throwing: error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { modelEntity in
                    Task {
                        do {
                            try await MainActor.run {
                                modelEntity.scale = SIMD3<Float>(repeating: config.airplaneScale)
                                
                                // Create and attach the cone
                                let coneMesh = try generateConeMesh(
                                    radius: config.coneRadius,
                                    height: config.coneHeight,
                                    segments: config.coneSegments
                                )
                                let coneMaterial = SimpleMaterial(color: .white, isMetallic: false)
                                let coneEntity = ModelEntity(mesh: coneMesh, materials: [coneMaterial])
                                
                                // Position the cone relative to the airplane
                                coneEntity.position = config.conePositionOffset
                                coneEntity.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
                                coneEntity.name = "cone"
                                
                                // Add physics and collision properties
                                addPhysicsAndCollision(to: coneEntity, coneMesh: coneMesh)
                                
                                // Add as a child and finish
                                modelEntity.addChild(coneEntity)
                                continuation.resume(returning: AirplaneModel(entity: modelEntity))
                            }
                        } catch {
                            // Handle errors during cone generation
                            print("❌ Error during model processing: \(error)")
                            continuation.resume(throwing: error)
                        }
                    }
                }
            ))
        }
    }
    
    // Custom cone mesh generator
    private static func generateConeMesh(radius: Float, height: Float, segments: Int) throws -> MeshResource {
        // Validate parameters
        guard radius > 0 else {
            throw MeshGenerationError.invalidRadius("Radius must be greater than 0")
        }
        guard height > 0 else {
            throw MeshGenerationError.invalidHeight("Height must be greater than 0")
        }
        guard segments >= 3 else {
            throw MeshGenerationError.invalidSegments("Segments must be at least 3")
        }
        
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        // Generate cone vertices and indices here...
        // (The actual mesh generation code can be implemented for realistic cones.)
        
        return try MeshResource.generate(from: .init(positions: positions, indices: indices))
        //  No exact matches in call to initializer
    }
    
    // Helper function for adding physics and collision logic to the cone
    private static func addPhysicsAndCollision(to coneEntity: ModelEntity, coneMesh: MeshResource) {
        coneEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            massProperties: PhysicsMassProperties(
                shape: .generateConvex(from: coneMesh),
                mass: 1.0
            ),
            material: .generate(friction: 0.8, restitution: 0.5),
            mode: .kinematic
        )
        
        coneEntity.components.set(
            CollisionComponent(
                shapes: [.generateConvex(from: coneMesh)],
                mode: .trigger
            )
        )
    }
}

// Custom error definitions for mesh generation
enum MeshGenerationError: Error {
    case invalidRadius(String)
    case invalidHeight(String)
    case invalidSegments(String)
}
