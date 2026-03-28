//  MotionManager.swift
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
    
    private(set) var attitudeStream: AsyncThrowingStream<AttitudeQuaternion, Error>?
    
    @discardableResult
    func startUpdates(updateInterval: TimeInterval = 1.0 / 60.0) -> AsyncThrowingStream<AttitudeQuaternion, Error> {
        if let attitudeStream { return attitudeStream }
        
        let stream = AsyncThrowingStream<AttitudeQuaternion, Error> { [weak self] continuation in
            guard let self else { return }
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.deviceMotionUnavailable)
                return
            }
            
            motionManager.deviceMotionUpdateInterval = updateInterval
            
            motionManager.startDeviceMotionUpdates(to: queue) { motion, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let motion else { return }
                
                let q = motion.attitude.quaternion
                continuation.yield(
                    AttitudeQuaternion(x: q.x, y: q.y, z: q.z, w: q.w)
                )
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.motionManager.stopDeviceMotionUpdates()
            }
        }
        
        attitudeStream = stream
        return stream
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        attitudeStream = nil
    }
}
