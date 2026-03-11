//  MotionManager.swift
//  

import CoreMotion

struct AttitudeQuaternion {
    let quaternion: CMQuaternion
}

class MotionManager {
    private var motionManager = CMMotionManager()
    private var continuation: AsyncThrowingStream<AttitudeQuaternion, Error>.Continuation?
    
    lazy var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error> = {
        AsyncThrowingStream { continuation in
            self.continuation = continuation
            
            guard self.motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: NSError(domain: "MotionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion not available"]))
                return
            }
            
            self.motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let continuation = self?.continuation else { return }
                
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion = motion else { return }
                
                let quaternion = AttitudeQuaternion(quaternion: motion.attitude.quaternion)
                continuation.yield(quaternion)
            }
        }
    }()
    
    init() {
        // The stream is lazily initialized when accessed
    }
    
    deinit {
        stopUpdates()
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        continuation?.finish()
    }
}
