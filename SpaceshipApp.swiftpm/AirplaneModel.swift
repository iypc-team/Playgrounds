// Updated AirplaneModel.swift (primary model used by ContentView)
// - Safe stream access (no force-unwrap)
// - Minor cleanups for iOS 16.6
// FighterModel.swift can be deleted as dead/unused duplicate.

import SwiftUI
import RealityKit
import CoreMotion
import Combine

@MainActor
final class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var loadError: String?
    @Published var currentModelName: String = "Spaceship"
    @Published var scale: Double = 1.0
    @Published var yaw: Angle = .zero
    @Published var pitch: Angle = .zero
    @Published var roll: Angle = .zero
    @Published var isMotionActive: Bool = false
    
    let availableModels: [String] = [
        "Airplane", "Airplane-2", "Spaceship",
        "fighter", "newFighter", "newEnemy", "smooth_ship"
    ]
    
    private let motionManager = MotionManager()
    private var motionTask: Task<Void, Never>?
    private var rotationTask: Task<Void, Never>?
    private var isRotating = false
    
    // MARK: - Model Loading
    func loadModel() {
        loadModel(named: currentModelName)
    }
    
    func loadModel(named name: String) {
        loadError = nil
        entity = nil
        currentModelName = name
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "usdz") else {
            loadError = "Model '\(name).usdz' not found in Resources."
            return
        }
        
        do {
            let loaded = try Entity.load(contentsOf: url)
            self.entity = loaded
            resetTransforms()
        } catch {
            loadError = "Failed to load \(name): \(error.localizedDescription)"
        }
    }
    
    private func resetTransforms() {
        scale = 1.0
        yaw = .zero
        pitch = .zero
        roll = .zero
    }
    
    // MARK: - Gesture Handlers
    func updateScale(with factor: Float) {
        let newScale = max(0.2, min(8.0, scale * Double(factor)))
        scale = newScale
    }
    
    func updateRotation(from translation: CGSize) {
        let sensitivity: Double = 0.006
        yaw += Angle.radians(translation.width * sensitivity)
        pitch += Angle.radians(-translation.height * sensitivity)
        
        let maxPitch = Angle.degrees(80)
        if pitch > maxPitch { pitch = maxPitch }
        if pitch < -maxPitch { pitch = -maxPitch }
    }
    
    // MARK: - Continuous Rotation
    func rotateModel() {
        cancelRotation()
        isRotating = true
        
        rotationTask = Task {
            while !Task.isCancelled && isRotating {
                try? await Task.sleep(for: .milliseconds(16))
                await MainActor.run {
                    self.yaw += Angle.degrees(0.8)
                }
            }
        }
    }
    
    func cancelRotation() {
        isRotating = false
        rotationTask?.cancel()
        rotationTask = nil
    }
    
    // MARK: - Device Motion Control (safe stream access)
    func startMotion() {
        guard !isMotionActive else { return }
        isMotionActive = true
        cancelRotation()
        
        motionManager.startUpdates(updateInterval: 1.0 / 60.0)
        
        motionTask = Task { [weak self] in
            guard let self else { return }
            guard let stream = self.motionManager.attitudeStream else {
                await MainActor.run { self.cancelMotion() }
                return
            }
            
            do {
                for try await attitude in stream {
                    await MainActor.run {
                        guard self.isMotionActive else { return }
                        self.applyDeviceAttitude(attitude.quaternion)
                    }
                }
            } catch {
                await MainActor.run {
                    self.loadError = "Motion error: \(error.localizedDescription)"
                    self.cancelMotion()
                }
            }
        }
    }
    
    private func applyDeviceAttitude(_ quat: CMQuaternion) {
        let q = simd_quatf(ix: Float(quat.x), iy: Float(quat.y), iz: Float(quat.z), r: Float(quat.w))
        let euler = quaternionToEuler(q)
        yaw = Angle.radians(Double(euler.yaw))
        pitch = Angle.radians(Double(euler.pitch))
        roll = Angle.radians(Double(euler.roll))
    }
    
    private func quaternionToEuler(_ q: simd_quatf) -> (pitch: Float, yaw: Float, roll: Float) {
        let sinr_cosp = 2 * (q.real * q.imag.x + q.imag.y * q.imag.z)
        let cosr_cosp = 1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        let roll = atan2(sinr_cosp, cosr_cosp)
        
        let sinp = 2 * (q.real * q.imag.y - q.imag.z * q.imag.x)
        let pitch = abs(sinp) >= 1 ? copysign(.pi / 2, sinp) : asin(sinp)
        
        let siny_cosp = 2 * (q.real * q.imag.z + q.imag.x * q.imag.y)
        let cosy_cosp = 1 - 2 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        let yaw = atan2(siny_cosp, cosy_cosp)
        
        return (pitch: pitch, yaw: yaw, roll: roll)
    }
    
    func cancelMotion() {
        isMotionActive = false
        motionTask?.cancel()
        motionTask = nil
        motionManager.stopUpdates()
    }
    
    func resetAll() {
        cancelRotation()
        cancelMotion()
        resetTransforms()
    }
    
    deinit {
        motionTask?.cancel()
        rotationTask?.cancel()
        motionManager.stopUpdates()
    }
}
