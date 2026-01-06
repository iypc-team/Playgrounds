// 
// animateRotationIncrement

import SwiftUI
import RealityKit

// Extend AirplaneModel with DRY gesture updates
extension AirplaneModel {
    func updateScale(with value: Float) {
        self.scale = value
        print("scale: \(self.scale)")
    }
    
    func updateRotation(from translation: CGSize) -> Angle {
        let dragAngle = Angle(degrees: Double(translation.height) * 1.0) // 0.01 default
        self.rotation = dragAngle
        print("dragAngle: \(dragAngle)")
        return dragAngle
    }
}

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 2.0
    @Published var rotationAngle: Float = 45.0 / 4 // Configurable rotation step angle in degrees
    @Published var rotation: Angle = .zero  // Current rotation angle for Y-axis (used by gestures and animations)
    
    // Constants for axis vectors and animation settings
    private let axisX = SIMD3<Float>(1, 0, 0)
    private let axisY = SIMD3<Float>(0, 1, 0)
    private let axisZ = SIMD3<Float>(0, 0, 1)
    private let fullRotationDegrees: Float = 360.0
    private let animationDuration: TimeInterval = 1.0  // Total duration for each axis rotation
    
    private var rotationTask: Task<Void, Never>?  // For cancellable rotation task
    
    /// Loads the airplane model asynchronously.
    func loadModel() {
        Task {
            do {
                let loadedEntity = try await Entity.load(named: "Airplane")
                DispatchQueue.main.async {
                    self.entity = loadedEntity
                }
            } catch {
                // Handle error (e.g., show alert in UI)
                print("Error loading model: \(error)")
            }
        }
    }
    
    /// Starts a smooth, cancellable rotation animation on X, Y, and Z axes sequentially.
    func rotateModel() {
        print("funk rotateModel()")
        // Cancel any existing rotation task
        rotationTask?.cancel()
        
        rotationTask = Task {
            guard let _ = entity else { return }
            
            let stepAngle = rotationAngle
            let stepsPerAxis = Int(fullRotationDegrees / stepAngle)
            let delayPerStep = animationDuration / Double(stepsPerAxis)
            
            // Rotate on X-axis
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                print("rotationAngle: \(rotationAngle)")
                await animateRotationIncrement(by: stepAngle, axis: axisX, delay: delayPerStep)
            }
            
            // Rotate on Y-axis
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: axisY, delay: delayPerStep)
            }
            
            // Rotate on Z-axis
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: axisZ, delay: delayPerStep)
            }
            
            // Reset rotation after sequence
            await resetRotation()
        }
    }
    
    /// Cancels the ongoing rotation animation if active.
    func cancelRotation() {
        print("func cancelRotation()")
        rotationTask?.cancel()
        rotationTask = nil
    }
    
    /// Resets the rotation state to zero.
    @MainActor
    func resetRotation() {
        print("func resetRotation()")
        rotation = .zero
    }
    
    /// Helper to animate a small rotation increment on the specified axis by updating model.rotation or entity.
    private func animateRotationIncrement(by angleDegrees: Float, axis: SIMD3<Float>, delay: TimeInterval) async {
        print("private func animateRotationIncrement()")
        let increment = Angle(degrees: Double(angleDegrees))
        await MainActor.run {
            if axis == axisY {  // Update Y-axis via model for consistency with gestures
                rotation += increment
            } else {
                // For X and Z axes, apply directly to entity
                if let entity = entity {
                    let quaternion = simd_quatf(angle: angleDegrees * .pi / 180, axis: axis)
                    entity.transform.rotation *= quaternion
                }
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}
