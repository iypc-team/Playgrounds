//  AirplaneViewModel.swift
// 
//  


import Foundation
import Combine
import simd

final class AirplaneViewModel: ObservableObject {
    @Published private(set) var orientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    @Published var revolutionsPerSecond: Float = 1.0  // Adjusted for step timing (1 step per second by default)
    @Published var rotationAxis: SIMD3<Float> = SIMD3<Float>(1, 0, 0)
    @Published var continuousOrientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)  // New for continuous rotation
    @Published var currentOrientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)  // Combined orientation for ARView
    
    private let stepDegrees: Float = 22.5
    private let totalDegrees: Float = 360.0
    private var currentDegrees: Float = 0.0
    private var timerCancellable: AnyCancellable?
    private var continuousTimerCancellable: AnyCancellable?  // New timer for continuous
    private var startDate = Date()
    
    init() {
        //        startClock()     // Auto‑start Rotation when created
    }
    
    deinit {
        stopContinuousRotation()  // New cleanup
        timerCancellable?.cancel()
    }
    
    // PUBLIC API – callers can restart the timer if they need to.
    func beginTiming() {
        resetRotation()
        startClock()
    }
    
    // New method to start continuous rotation
    func startContinuousRotation(axis: SIMD3<Float> = SIMD3<Float>(0, 1, 0), speed: Float = 1.0) {
        stopContinuousRotation()  // Stop any existing continuous timer
        continuousTimerCancellable = Timer.publish(every: 0.016, tolerance: 0.001, on: .main, in: .common)
            .autoconnect()
            .scan(0.0) { (accum, _) in accum + 0.016 * speed }  // Accumulate time
            .sink { [weak self] time in
                let radians = Float(time) * .pi * 2 * speed  // Full rotations over time
                self?.continuousOrientation = simd_quaternion(radians, normalize(axis))
                self?.currentOrientation = self?.continuousOrientation ?? simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
            }
    }
    
    // New method to stop continuous rotation
    func stopContinuousRotation() {
        continuousTimerCancellable?.cancel()
        continuousTimerCancellable = nil
        continuousOrientation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)  // Reset
        currentOrientation = orientation
    }
    
    // PRIVATE implementation detail
    private func startClock() {
        // Timer interval based on revolutionsPerSecond (e.g., 1 RPS = 1 step per second)
        let interval = 1.0 / Double(revolutionsPerSecond)
        timerCancellable = Timer.publish(every: interval, tolerance: 0.001, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }
    
    private func tick() {
        if currentDegrees < totalDegrees {
            currentDegrees += stepDegrees
            let radians = currentDegrees * .pi / 180.0
            orientation = simd_quaternion(radians, normalize(rotationAxis))
            currentOrientation = orientation
        } else {
            resetRotation()
        }
    }
    
    private func resetRotation() {
        currentDegrees = 0.0
        orientation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        currentOrientation = orientation
    }
}
