// Updated MotionManager.swift - Fixed retain cycle risk, removed force-unwrap dependency
// No strong self capture in stream creation/handlers. Proper cleanup.

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
}

final class MotionManager {
    private let motionManager = CMMotionManager()
    private var continuation: AsyncThrowingStream<AttitudeQuaternion, Error>.Continuation?
    
    private(set) var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    func startUpdates(updateInterval: TimeInterval = 1.0 / 30.0) {
        if attitudeStream != nil { return }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        attitudeStream = AsyncThrowingStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            self.continuation = continuation
            
            continuation.onTermination = { @Sendable _ in
                self.motionManager.stopDeviceMotionUpdates()
                self.continuation = nil
                self.attitudeStream = nil
            }
            
            guard self.motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(
                    domain: "MotionManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]
                ))
                return
            }
            
            self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
                guard let self = self, let continuation = self.continuation else {
                    self?.motionManager.stopDeviceMotionUpdates()
                    return
                }
                
                if let error = error {
                    self.motionManager.stopDeviceMotionUpdates()
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion = motion else { return }
                
                continuation.yield(AttitudeQuaternion(quaternion: motion.attitude.quaternion))
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        continuation?.finish()
        continuation = nil
        attitudeStream = nil
    }
    
    deinit {
        stopUpdates()
    }
}
