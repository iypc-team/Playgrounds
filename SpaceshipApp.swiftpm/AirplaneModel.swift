// 
//
// 

import SwiftUI
import RealityKit

// Extend AirplaneModel with DRY gesture updates
extension AirplaneModel {
    func updateScale(with value: Float) {
        self.scale = value
    }
    
    func updateRotation(from translation: CGSize) {
        let dragAngle = Angle(degrees: Double(translation.height) * 1.0)
        self.yaw = dragAngle  // Unified: Update yaw for Y-axis drag
    }
}

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 2.0
    @Published var yaw: Angle = .zero    // Y-axis rotation
    @Published var pitch: Angle = .zero  // X-axis rotation
    @Published var roll: Angle = .zero   // Z-axis rotation
    
    // Constants for axis vectors and animation settings
    private let fullRotationDegrees: Float = 360.0
    private let animationDuration: TimeInterval = 1.0
    
    private var rotationTask: Task<Void, Never>?
    
    func loadModel() {
        Task {
            do {
                let loadedEntity = try await Entity.load(named: "Airplane")
                DispatchQueue.main.async {
                    self.entity = loadedEntity
                }
            } catch {
                print("Error loading model: \(error)")
            }
        }
    }
    
    func rotateModel() {
        rotationTask?.cancel()
        
        rotationTask = Task {
            guard let _ = entity else { return }
            
            let stepAngle: Float = 22.5  // Use a constant for clarity
            let stepsPerAxis = Int(fullRotationDegrees / stepAngle)
            let delayPerStep: TimeInterval = 0.5  // Set delay to 0.5 seconds between each rotation step
            
            // Rotate on X-axis (pitch)
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: .pitch, delay: delayPerStep)
            }
            
            // Rotate on Y-axis (yaw)
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: .yaw, delay: delayPerStep)
            }
            
            // Rotate on Z-axis (roll)
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: .roll, delay: delayPerStep)
            }
            
            await resetRotation()
        }
    }
    
    func cancelRotation() {
        rotationTask?.cancel()
        rotationTask = nil
    }
    
    @MainActor
    func resetRotation() {
        yaw = .zero
        pitch = .zero
        roll = .zero
    }
    
    private enum RotationAxis {
        case yaw, pitch, roll
    }
    
    private func animateRotationIncrement(by angleDegrees: Float, axis: RotationAxis, delay: TimeInterval) async {
        let increment = Angle(degrees: Double(angleDegrees))
        await MainActor.run {
            switch axis {
            case .yaw:
                yaw += increment
            case .pitch:
                pitch += increment
            case .roll:
                roll += increment
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}
