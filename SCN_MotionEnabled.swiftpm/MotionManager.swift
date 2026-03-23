// MotionManager.swift
// 

import CoreMotion
import Foundation

enum MotionError: Error {
    case deviceMotionUnavailable
}

struct AttitudeQuaternion {
    let x: Double
    let y: Double
    let z: Double
    let w: Double
}

final class MotionManager {
    
    private let motionManager = CMMotionManager()
    
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.qualityOfService = .userInteractive
        return q
    }()
    
    private(set) var attitudeStream:
    AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    func startUpdates()
    -> AsyncThrowingStream<AttitudeQuaternion, Error> {
        
        AsyncThrowingStream { continuation in
            
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.deviceMotionUnavailable)
                return
            }
            
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            
            motionManager.startDeviceMotionUpdates(to: queue) {
                motion, error in
                
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let motion else { return }
                
                let q = motion.attitude.quaternion
                
                continuation.yield(
                    AttitudeQuaternion(
                        x: q.x,
                        y: q.y,
                        z: q.z,
                        w: q.w
                    )
                )
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.motionManager.stopDeviceMotionUpdates()
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

