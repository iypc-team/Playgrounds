// AirplaneModel.swift
// Fully optimized with USDZ caching + instant cloning for fast model switching
// Updated for iOS 16.6 compliance (class name aligned with ContentView / RealityKitView)

import SwiftUI
import RealityKit
import CoreMotion

// MARK: - Gesture Helpers
extension AirplaneModel {
    func updateScale(with value: Float) {
        self.scale = value
    }
    
    func updateRotation(from translation: CGSize) {
        let dragAngle = Angle(degrees: Double(translation.height) * 1.0)
        self.yaw = dragAngle
    }
}

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 1.0 / 15
    
    @Published var pitch: Angle = .zero
    @Published var yaw: Angle = .zero
    @Published var roll: Angle = .zero
    
    // Motion
    private let motionManager = MotionManager()
    private var motionTask: Task<Void, Never>?
    @Published var isMotionActive = false
    
    // Rotation & Loading
    private var rotationTask: Task<Void, Never>?
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 2.0
    @Published var isLoading = false
    @Published var loadError: String?
    
    private let fullRotationDegrees: Float = 360.0
    
    // === PERFORMANCE OPTIMIZATION: In-memory cache ===
    private var modelCache: [String: Entity] = [:]
    
    // Model Selection
    @Published var currentModelName: String = "fighter"
    let availableModels: [String] = [
        "newEnemy", "smooth_ship", "newFighter", "fighter",
        "Spaceship", "Airplane", "Airplane-2"
    ]
    
    // MARK: - Model Loading (Optimized)
    
    func loadModel(named name: String? = nil) {
        if let name = name {
            currentModelName = name
        }
        isLoading = true
        loadError = nil
        
        Task {
            await loadOrCloneModel()
        }
    }
    
    private func loadOrCloneModel() async {
        let name = currentModelName
        
        // Fast path: Clone from cache (no disk I/O)
        if let cachedEntity = modelCache[name] {
            let clonedEntity = await cachedEntity.clone(recursive: true)
            
            await MainActor.run {
                self.entity = clonedEntity
                self.scale = 1.0 / 15
                self.resetRotation()
                self.isLoading = false
                self.loadError = nil
            }
            return
        }
        
        // Slow path: Load from disk, cache it, then clone
        await loadModelWithRetry(attempt: 1, modelName: name)
    }
    
    private func loadModelWithRetry(attempt: Int, modelName: String) async {
        do {
            let loadedEntity = try await Entity.load(named: modelName)
            
            // Cache the original entity
            modelCache[modelName] = loadedEntity
            
            // Clone so we never mutate the cached version
            let clonedEntity = await loadedEntity.clone(recursive: true)
            
            await MainActor.run {
                self.entity = clonedEntity
                self.scale = 1.0 / 15
                self.resetRotation()
                self.isLoading = false
                self.loadError = nil
            }
        } catch {
            print("Error loading model '\(modelName)' (attempt \(attempt)): \(error)")
            
            if attempt < maxRetryAttempts {
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                await loadModelWithRetry(attempt: attempt + 1, modelName: modelName)
            } else {
                await MainActor.run {
                    self.isLoading = false
                    self.loadError = "Failed to load \(modelName) after \(maxRetryAttempts) attempts"
                }
            }
        }
    }
    
    // MARK: - Motion Control
    
    func startMotion() {
        guard !isMotionActive else { return }
        motionManager.startUpdates(updateInterval: 1.0 / 30.0)
        isMotionActive = true
        
        motionTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await attitude in self.motionManager.attitudeStream! {
                    await MainActor.run {
                        self.updateFromQuaternion(attitude.quaternion)
                    }
                }
            } catch {
                print("Motion stream error: \(error)")
            }
            await MainActor.run { self.isMotionActive = false }
        }
    }
    
    func cancelMotion() {
        motionTask?.cancel()
        motionTask = nil
        motionManager.stopUpdates()
        isMotionActive = false
    }
    
    @MainActor
    private func updateFromQuaternion(_ quat: CMQuaternion) {
        let qx = quat.x, qy = quat.y, qz = quat.z, qw = quat.w
        
        // Roll (X)
        let sinr_cosp = 2 * (qw * qx + qy * qz)
        let cosr_cosp = 1 - 2 * (qx * qx + qy * qy)
        var rollRad = atan2(sinr_cosp, cosr_cosp)
        
        // Pitch (Y)
        let sinp = 2 * (qw * qy - qz * qx)
        var pitchRad = abs(sinp) >= 1 ? copysign(.pi/2, sinp) : asin(sinp)
        
        // Yaw (Z)
        let siny_cosp = 2 * (qw * qz + qx * qy)
        let cosy_cosp = 1 - 2 * (qy * qy + qz * qz)
        var yawRad = atan2(siny_cosp, cosy_cosp)
        
        // Normalize to [-π, π]
        pitchRad = fmod(pitchRad + .pi, 2 * .pi) - .pi
        yawRad   = fmod(yawRad   + .pi, 2 * .pi) - .pi
        rollRad  = fmod(rollRad  + .pi, 2 * .pi) - .pi
        
        let sensitivity: Double = 0.8
        pitch = Angle(radians: pitchRad * sensitivity)
        yaw   = Angle(radians: yawRad * sensitivity)
        roll  = Angle(radians: rollRad * sensitivity)
    }
    
    // MARK: - Rotation Demo
    
    func rotateModel() {
        rotationTask?.cancel()
        rotationTask = Task {
            guard let _ = entity else { return }
            let stepAngle: Float = 22.5
            let stepsPerAxis = Int(fullRotationDegrees / stepAngle)
            let delayPerStep: TimeInterval = 1.0
            
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: .pitch, delay: delayPerStep)
            }
            for _ in 0..<stepsPerAxis {
                if Task.isCancelled { return }
                await animateRotationIncrement(by: stepAngle, axis: .yaw, delay: delayPerStep)
            }
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
    
    private enum RotationAxis { case yaw, pitch, roll }
    
    private func animateRotationIncrement(by angleDegrees: Float, axis: RotationAxis, delay: TimeInterval) async {
        let increment = Angle(degrees: Double(angleDegrees))
        await MainActor.run {
            switch axis {
            case .yaw:   yaw += increment
            case .pitch: pitch += increment
            case .roll:  roll += increment
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    @MainActor
    func resetAll() {
        cancelMotion()
        cancelRotation()
        resetRotation()
    }
}
