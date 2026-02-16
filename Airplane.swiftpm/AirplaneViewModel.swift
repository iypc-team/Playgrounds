//
//  AirplaneViewModel.swift
//  

import SwiftUI
import RealityKit
import Combine

class AirplaneViewModel: ObservableObject {
    @Published var currentOrientation: simd_quatf = .init(ix: 0, iy: 0, iz: 0, r: 1)
    
    private var rotationTask: Task<Void, Never>?
    
    func startContinuousRotation(axis: SIMD3<Float>, speed: Float) {
        stopContinuousRotation()
        
        rotationTask = Task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 16_666_666)  // ~60 FPS
                    await MainActor.run {
                        let rotation = simd_quatf(angle: speed, axis: axis)
                        currentOrientation = rotation * currentOrientation
                    }
                } catch {
                    break
                }
            }
        }
    }
    
    func stopContinuousRotation() {
        rotationTask?.cancel()
        rotationTask = nil
    }
}
