// MotionService
// 

import CoreMotion
import Foundation

enum MotionError: Error {
    case unavailable
    case failed(Error)
}

final class MotionService {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    // MARK: Public API
    /// Async stream of quaternions expressed in the xMagneticNorthZVertical reference frame.
    func quaternionStream(
        updateInterval: TimeInterval = 1.0 / 60.0   // 60 Hz by default
    ) -> AsyncThrowingStream<CMQuaternion, Error> {
        
        AsyncThrowingStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.unavailable)
                return
            }
            
            manager.deviceMotionUpdateInterval = updateInterval
            
            // Choose the reference frame you asked for:
            // .xMagneticNorthZVertical aligns X→magnetic north, Z→vertical.
            manager.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical,
                to: queue
            ) { [weak self] motion, error in
                guard let self = self else { return }
                
                if let error = error {
                    continuation.finish(throwing: MotionError.failed(error))
                    self.manager.stopDeviceMotionUpdates()
                    return
                }
                
                guard let quat = motion?.attitude.quaternion else { return }
                
                continuation.yield(quat)
            }
            
            // Clean‑up when the consumer cancels the stream:
            continuation.onTermination = { @Sendable _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}


