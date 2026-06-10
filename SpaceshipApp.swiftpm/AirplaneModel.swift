// AirplaneModel.swift
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    @Published var scale: Float = 1.0
    @Published var pitch: Angle = .zero
    @Published var yaw: Angle = .zero
    @Published var roll: Angle = .zero
    
    @Published var loadError: String?
    
    private var rotationTask: Task<Void, Never>?
    
    private let minScale: Float = 0.2
    private let maxScale: Float = 8.0
    private let rotationStep: Float = 15.0
    private let rotationDelay: TimeInterval = 0.08
    
    func loadModel() {
        loadError = nil
        Task {
            await loadModelWithRetry(attempt: 1)
        }
    }
    
    func updateScale(with value: Float) {
        scale = max(minScale, min(maxScale, value))
    }
    
    func updateRotation(from translation: CGSize) {
        let yawDelta = Double(translation.width) * 0.4
        let pitchDelta = Double(translation.height) * 0.4
        yaw += Angle(degrees: yawDelta)
        pitch += Angle(degrees: pitchDelta)
    }
    
    func rotateModel() {
        cancelRotation()
        rotationTask = Task {
            guard entity != nil else { return }
            await rotateAxis(.pitch, degrees: 360)
            await rotateAxis(.yaw, degrees: 360)
            await rotateAxis(.roll, degrees: 360)
            await MainActor.run { resetRotation() }
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
    
    private func loadModelWithRetry(attempt: Int) async {
        do {
            let loaded = try await Entity.load(named: "fighter")
            await MainActor.run {
                self.entity = loaded
                self.loadError = nil
            }
        } catch {
            if attempt < 3 {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await loadModelWithRetry(attempt: attempt + 1)
            } else {
                await MainActor.run {
                    self.loadError = error.localizedDescription
                }
            }
        }
    }
    
    private func rotateAxis(_ axis: RotationAxis, degrees: Float) async {
        let steps = Int(degrees / rotationStep)
        for _ in 0..<steps {
            if Task.isCancelled { return }
            await MainActor.run {
                let increment = Angle(degrees: Double(rotationStep))
                switch axis {
                case .yaw:   yaw += increment
                case .pitch: pitch += increment
                case .roll:  roll += increment
                }
            }
            try? await Task.sleep(nanoseconds: UInt64(rotationDelay * 1_000_000_000))
        }
    }
}
