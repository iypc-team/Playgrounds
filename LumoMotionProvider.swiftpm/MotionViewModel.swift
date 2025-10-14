// 
//

import CoreMotion
import Combine

class MotionViewModel: ObservableObject {
    private var motionManager = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var quaternion: Quaternion? = nil
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 1.0 // 50 Hz
        
        let stream = AsyncThrowingStream<Quaternion, Error> { continuation in
            motionManager.startDeviceMotionUpdates(to: .main) { (deviceMotion, error) in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let attitude = deviceMotion?.attitude else { return }
                let quaternion = Quaternion(x: attitude.quaternion.x,
                                            y: attitude.quaternion.y,
                                            z: attitude.quaternion.z,
                                            w: attitude.quaternion.w)
                continuation.yield(quaternion)
            }
        }
        
        Task {
            do {
                for try await quaternion in stream {
                    await MainActor.run {
                        self.quaternion = quaternion
                    }
                }
            } catch {
                // Handle the error
                print("Stream ended with error: \(error)")
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

//import SwiftUI
//import CoreMotion
//final class MotionViewModel: ObservableObject {
//    @Published var quaternionString = "—"
//    private let provider = MotionProvider()
//    private var task: Task<Void, Never>? = nil
//    
//    func start() {
//        task = Task {
//            for await quat in provider.quaternionStream() {
//                await MainActor.run {
//                    quaternionString = String(
//                        format: "(%.3f, %.3f, %.3f, %.3f)",
//                        quat.x, quat.y, quat.z, quat.w
//                    )
//                }
//            }
//        }
//    }
//    
//    func stop() {
//        task?.cancel()
//        task = nil
//    }
//}
