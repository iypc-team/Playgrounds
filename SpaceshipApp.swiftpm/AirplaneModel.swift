//
// Modified AirplaneModel.swift with retry mechanism for failed loads

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
    @Published var scale: Float = 1.0
    
    @Published var pitch: Angle = .zero  // X-axis rotation
    @Published var yaw: Angle = .zero    // Y-axis rotation
    @Published var roll: Angle = .zero   // Z-axis rotation
    
    // Constants for axis vectors and animation settings
    private let fullRotationDegrees: Float = 360.0
    private let animationDuration: TimeInterval = 0.5
    
    private var rotationTask: Task<Void, Never>?
    
    // Add retry-related properties
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 2.0  // Delay between retries in seconds
    @Published var isLoading = false
    @Published var loadError: String?
    
    func loadModel() {
        isLoading = true
        loadError = nil
        Task {
            await loadModelWithRetry(attempt: 1)
        }
    }
    
    private func loadModelWithRetry(attempt: Int) async {
        do {
            let loadedEntity = try await Entity.load(named: "Spaceship")
            DispatchQueue.main.async {
                self.entity = loadedEntity
                self.isLoading = false
                self.loadError = nil
            }
        } catch {
            print("Error loading model (attempt \(attempt)): \(error)")
            if attempt < maxRetryAttempts {
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                await loadModelWithRetry(attempt: attempt + 1)
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.loadError = "Failed to load model after \(self.maxRetryAttempts) attempts: \(error.localizedDescription)"
                    print(self.loadError!)
                }
            }
        }
    }
    
    // ... (rest of the class remains unchanged)
    
    func rotateModel() {
        rotationTask?.cancel()
        
        rotationTask = Task {
            guard let _ = entity else { return }
            
            let stepAngle: Float = 22.5  // Use a constant for clarity
            let stepsPerAxis = Int(fullRotationDegrees / stepAngle)
            let delayPerStep: TimeInterval = 1.0  // Set delay to 0.5 seconds between each rotation step
            
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
