//  'identity' is inaccessable due to 'internal' protection level
// 

import Foundation
import Combine
import simd

final class AirplaneViewModel: ObservableObject {
    @Published private(set) var orientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    @Published var revolutionsPerSecond: Float = 0.2
    @Published var rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)
    
    private var timerCancellable: AnyCancellable?
    private var startDate = Date()
    
    init() {
        startClock()               // Auto‑start when created
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    // PUBLIC API – callers can restart the timer if they need to.
    func beginTiming() {
        startClock()
    }
    
    // PRIVATE implementation detail
    private func startClock() {
        timerCancellable = Timer.publish(every: 1.0/60.0,
                                         tolerance: 0.001,
                                         on: .main,
                                         in: .common)
        .autoconnect()
        .sink { [weak self] _ in self?.tick() }
    }
    
    private func tick() {
        let elapsed = Float(Date().timeIntervalSince(startDate))
        let angle = elapsed * .pi * 2 * revolutionsPerSecond
        orientation = simd_quaternion(angle, normalize(rotationAxis))
    }
}
