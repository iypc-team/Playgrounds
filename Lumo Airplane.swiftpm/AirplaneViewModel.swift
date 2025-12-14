//  'identity' is inaccessable due to 'internal' protection level
// 
// orientation:

import Foundation
import Combine
import simd

final class AirplaneViewModel: ObservableObject {
    @Published private(set) var orientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    @Published var revolutionsPerSecond: Float = 1.0  // Adjusted for step timing (1 step per second by default)
    @Published var rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)
    
    private let stepDegrees: Float = 22.5
    private let totalDegrees: Float = 360.0
    private var currentDegrees: Float = 0.0
    private var timerCancellable: AnyCancellable?
    private var startDate = Date()
    
    init() { 
        startClock()       // Auto‑start when created
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    // PUBLIC API – callers can restart the timer if they need to.
    func beginTiming() {
        resetRotation()
        startClock()
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
        } else {
            // Stop at 360°
            timerCancellable?.cancel()
        }
    }
    
    private func resetRotation() {
        currentDegrees = 0.0
        orientation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }
}


////'identity' is inaccessable due to 'internal' protection level
//// 
//// orientation:
//
//import Foundation
//import Combine
//import simd
//
//final class AirplaneViewModel: ObservableObject {
//    @Published private(set) var orientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
//    @Published var revolutionsPerSecond: Float = 2.0 // 0.2
//    @Published var rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)
//    
//    private var timerCancellable: AnyCancellable?
//    private var startDate = Date()
//    
//    init() { 
//        startClock()       // Auto‑start when created
//    }
//    
//    deinit {
//        timerCancellable?.cancel()
//    }
//    
//    // PUBLIC API – callers can restart the timer if they need to.
//    func beginTiming() {
//        startClock()
//    }
//    
//    // PRIVATE implementation detail
//    private func startClock() {
//        timerCancellable = Timer.publish(every: 2.0, tolerance: 0.001, on: .main, in: .common)
//        .autoconnect()
//        .sink { [weak self] _ in self?.tick() }
//    }
//    
//    private func tick() {
//        let elapsed = Float(Date().timeIntervalSince(startDate))
//        let angle = elapsed * .pi * 2 * revolutionsPerSecond
//        orientation = simd_quaternion(angle, normalize(rotationAxis))
////        orientation.debugDescription
////        print("orientation: \(orientation.debugDescription)")
//    }
//}
