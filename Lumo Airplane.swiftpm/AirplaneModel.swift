//  Value of type 'LoadRequest<ModelEntity>' has no member 'value'
// cannot convert valur of type 'LoadRequest<ModelEntity> to expected argument type 'ModelEntity'

import SwiftUI
import RealityKit
import Combine   // only needed if you want a timer publisher
import simd

/// Simple wrapper around the 3‑D entity. It can be expanded later
/// (e.g., with additional metadata or multiple assets).
struct AirplaneModel {
    /// The RealityKit entity that represents the airplane.
    let entity: ModelEntity
    
    /// Fixed rotation axis – you can expose this to the VM if you want it configurable.
    let rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)   // Y‑axis (yaw)
    
    /// Asynchronous factory – keeps the UI thread free.
    static func load() async throws -> AirplaneModel {
        // ✅ In the current SDK, `loadModelAsync` returns the ModelEntity itself.
        let modelEntity = try await ModelEntity.loadModelAsync(named: "Airplane")
        
        // Optional: centre the model, set an initial scale, etc.
        // modelEntity.scale = SIMD3<Float>(repeating: 0.5)
        
        // ✅ Return the wrapper; no cast needed.
        return AirplaneModel(entity: modelEntity)
    }
}

