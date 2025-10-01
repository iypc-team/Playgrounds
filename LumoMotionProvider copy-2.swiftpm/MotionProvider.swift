// 
// 

import CoreMotion
import Foundation

/// Errors that can be emitted from the quaternion stream.
enum MotionError: LocalizedError {
    case unavailable          // Core Motion not supported on this device
    case notAuthorized        // User denied motion & fitness permission
    case startFailed(String)  // Any other failure while starting updates
    
    var errorDescription: String? {
        switch self {
        case .unavailable:      return "Core Motion is not available on this device."
        case .notAuthorized:    return "Motion & Fitness permission was not granted."
        case .startFailed(let msg): return "Failed to start motion updates: \(msg)"
        }
    }
}

/// Async stream that yields CMQuaternion values.
func quaternionStream(
    updateInterval: TimeInterval = 1.0 / 60.0   // 60 Hz default
) -> AsyncThrowingStream<CMQuaternion, Error> {
    
    AsyncThrowingStream { continuation in
        
        // 2️⃣ Create the manager (retain it for the lifetime of the stream)
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = updateInterval
        
        // 1️⃣ Guard against missing hardware
        guard manager.isDeviceMotionAvailable else {
            continuation.finish(throwing: MotionError.unavailable)
            return
        }
        
        // 3️⃣ Permission check (iOS 14+)
        if #available(iOS 14.0, *) {
            manager.queryActivityStarting(from: Date(),
                                          to: Date(),
                                          withHandler: { _, _ in })
        }
        
        // 4️⃣ Start updates on a dedicated queue
        let queue = OperationQueue()
        queue.name = "com.example.motionQueue"
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        
        manager.startDeviceMotionUpdates(to: queue) { motion, error in
            // 5️⃣ Propagate any Core Motion error
            if let err = error {
                continuation.finish(throwing: MotionError.startFailed(err.localizedDescription))
                manager.stopDeviceMotionUpdates()
                return
            }
            
            // 6️⃣ Guard against nil motion (shouldn't happen, but be defensive)
            guard let attitude = motion?.attitude else {
                continuation.finish(throwing: MotionError.startFailed("Missing attitude data"))
                manager.stopDeviceMotionUpdates()
                return
            }
            
            // 7️⃣ Emit the quaternion
            continuation.yield(attitude.quaternion)
        }
        
        // 8️⃣ Clean‑up when the consumer stops or cancels
        continuation.onTermination = { @Sendable termination in
            manager.stopDeviceMotionUpdates()
            queue.cancelAllOperations()
        }
    }
}
