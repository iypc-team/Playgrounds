//  MotionManager.swift
//  

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
}

class MotionManager {
    private var motionManager = CMMotionManager()
    private var continuation: AsyncThrowingStream<AttitudeQuaternion, Error>.Continuation?
    private var lastYieldTime: Date?
    
    var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    func startUpdates() {
        attitudeStream = AsyncThrowingStream { continuation in
            self.continuation = continuation
            
            guard self.motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(domain: "MotionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]))
                return
            }
            
            self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
                guard let self = self, let continuation = self.continuation else { return }
                
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion = motion else { return }
                
                // Throttle to once per second
                let currentTime = Date()
                if let lastTime = self.lastYieldTime, currentTime.timeIntervalSince(lastTime) < 1.0 {
                    return
                }
                
                self.lastYieldTime = currentTime
                let quaternion = AttitudeQuaternion(quaternion: motion.attitude.quaternion)
                continuation.yield(quaternion)
            }
        }
    }
    
    init() {
        // Initialization
    }
    
    deinit {
        stopUpdates()
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        continuation?.finish()
        attitudeStream = nil
        lastYieldTime = nil
    }
}
