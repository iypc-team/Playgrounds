//  AirplaneModel.swift
//
//  white

import RealityKit
import Combine

struct AirplaneModel {
    let entity: ModelEntity
    let rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    private static let conePositionOffset: SIMD3<Float> = SIMD3<Float>(0, 0, 0.45)
    
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
                            
                            // Create and attach the cone
                            let coneMesh = generateConeMesh(radius: 0.2, height: 0.5, segments: 36)
                            let coneMaterial = SimpleMaterial(color: .white, isMetallic: false)
                            let coneEntity = ModelEntity(mesh: coneMesh, materials: [coneMaterial])
                            
                            // Position the cone relative to the airplane
                            coneEntity.position = conePositionOffset
                            
                            coneEntity.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
                            
                            // Set name for collision detection
                            coneEntity.name = "cone"
                            
                            // Add physics properties to the cone
                            coneEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                                massProperties: PhysicsMassProperties(shape: .generateConvex(from: coneMesh), mass: 1.0),
                                material: .generate(friction: 0.8, restitution: 0.5),
                                mode: .kinematic // was .static
                            )
                            
                            // Add collision component for collision events (trigger)
                            coneEntity.components.set(
                                CollisionComponent(
                                    shapes: [.generateConvex(from: coneMesh)],
                                    mode: .trigger
                                )
                            )
                            
                            // Add as a child
                            modelEntity.addChild(coneEntity)
                        }
                        continuation.resume(returning: AirplaneModel(entity: modelEntity))
                    }
                }
            ))
        }
    }
    
    // Custom cone mesh generator
    private static func generateConeMesh(radius: Float, height: Float, segments: Int) -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        // Apex (top point)
        let apex = SIMD3<Float>(0, height / 2, 0)
        positions.append(apex)
        normals.append(normalize(SIMD3<Float>(0, 1, 0)))  // Pointing up
        
        // Base circle vertices
        for i in 0..<segments {
            let angle = Float(i) * (2.0 * .pi / Float(segments))
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            positions.append(SIMD3<Float>(x, -height / 2, z))
            normals.append(normalize(SIMD3<Float>(x, 0, z)))  // Radial normals
        }
        
        // Base center for the bottom cap
        let baseCenterIndex = UInt32(positions.count)
        positions.append(SIMD3<Float>(0, -height / 2, 0))
        normals.append(SIMD3<Float>(0, -1, 0))  // Pointing down
        
        // Generate indices for sides
        for i in 0..<segments {
            let next = (i + 1) % segments
            indices.append(0)  // Apex
            indices.append(UInt32(i + 1))
            indices.append(UInt32(next + 1))
        }
        
        // Generate indices for base
        for i in 0..<segments {
            let next = (i + 1) % segments
            indices.append(baseCenterIndex)
            indices.append(UInt32(next + 1))
            indices.append(UInt32(i + 1))
        }
        
        // Build RealityKit mesh descriptor (updated API usage)
        var desc = MeshDescriptor()
        desc.positions = MeshBuffer(positions)
        desc.normals = MeshBuffer(normals)
        desc.primitives = .triangles(indices)
        
        return try! MeshResource.generate(from: [desc])
    }
}
