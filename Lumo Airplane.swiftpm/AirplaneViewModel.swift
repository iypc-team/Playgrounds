// 
// 

import

// View‑Model core
class AirplaneViewModel: ObservableObject {
    @Published var orientation = simd_quatf.identity
    @Published var revsPerSec: Float = 0.2
    @Published var axis = SIMD3<Float>(0,1,0)
    
    private var timer: AnyCancellable?
    private let start = Date()
    
    init() { startTimer() }
    private func startTimer() {
        timer = Timer.publish(every: 1/60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.update() }
    }
    private func update() {
        let t = Float(Date().timeIntervalSince(start))
        let angle = t * .pi * 2 * revsPerSec
        orientation = simd_quaternion(angle, normalize(axis))
    }
}

// SwiftUI view (iOS 16)

