// MotionService
// 

import CoreMotion
import Foundation

enum MotionError: Error {
    case unavailable
    case failed(Error)
}

enum CMMagneticFieldCalibrationAccuracy : Int {
    case uncalibrated = -1
    case low = 0
    case medium = 1
    case high = 2
}

extension OperationQueue {
    /// Returns the number of operations that are still waiting to be executed.
    var waitingCount: Int {
        // `operations` gives you all operations that are either executing,
        // pending, or have finished but haven’t been removed yet.
        // Filtering out the ones that are already finished gives a true “queue length”.
        return operations.filter { !$0.isFinished }.count
    }
    var count: Int {
        // `operations` gives you all operations that are either executing,
        // pending, or have finished but haven’t been removed yet.
        // Filtering out the ones that are already finished gives a true “queue length”.
        return operations.filter { $0.isFinished }.count
    }
}

final class MotionService {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    init() {
        queue.name = "MotionQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        print("\(queue.debugDescription)")
    }
    
    func deviceCalibration() {
        if let deviceMotion = manager.deviceMotion {
            let magAccuracy = deviceMotion.magneticField.accuracy
            switch magAccuracy {
            case .high:
                print("High magnetic field accuracy")
            case .medium:
                print("Medium magnetic field accuracy")
            case .low:
                print("Low magnetic field accuracy")
            case .uncalibrated:
                print("Uncalibrated magnetic field")
            @unknown default:
                print("Unknown accuracy")
            }
        }
    }
    
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
                print("\(quat)\n")
                print("waitingCount: \(queue.waitingCount)")
                print("count: \(queue.count)")
                continuation.yield(quat)
            }
            
            // Clean‑up when the consumer cancels the stream:
            continuation.onTermination = { @Sendable _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}
