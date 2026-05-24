// MotionManager.swift
// Production-ready motion tracking with explicit typing for better compiler inference.

import CoreMotion

// MARK: - Constants
private enum MotionConstants {
    static let calibrationInterval: TimeInterval = 0.1
    static let defaultStreamInterval: TimeInterval = 1.0 / 60.0 
    static let queueName: String = "com.YourApp.motionQueue"
}

// MARK: - CMAttitude Extension
extension CMAttitude {
    func relative(to reference: CMAttitude) -> CMAttitude {
        let copy = self.copy() as! CMAttitude
        copy.multiply(byInverseOf: reference)
        return copy
    }
    
    var attitudeQuaternion: AttitudeQuaternion {
        AttitudeQuaternion(quaternion: self.quaternion)
    }
}

// MARK: - Data Models
struct AttitudeQuaternion {
    let quaternion: CMQuaternion
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    init(quaternion: CMQuaternion) {
        self.quaternion = quaternion
        
        self.roll = atan2(
            2 * (quaternion.w * quaternion.x + quaternion.y * quaternion.z),
            1 - 2 * (quaternion.x * quaternion.x + quaternion.y * quaternion.y)
        )
        
        self.pitch = asin(max(-1.0, min(1.0,
                                        2 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x)
                                       )))
        
        self.yaw = atan2(
            2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
            1 - 2 * (quaternion.y * quaternion.y + quaternion.z * quaternion.z)
        )
    }
}

struct MotionData {
    let attitude: AttitudeQuaternion
    let gravity: CMAcceleration
    let rotationRate: CMRotationRate
    let timestamp: TimeInterval
}

// MARK: - Motion Errors
enum MotionError: Error, LocalizedError {
    case unavailable
    case motionUpdateFailed
    case calibrationFailed
    
    var errorDescription: String? {
        switch self {
        case .unavailable:          return "Device motion is not available on this device"
        case .motionUpdateFailed:   return "Motion update failed - no data received"
        case .calibrationFailed:    return "Failed to calibrate motion sensor"
        }
    }
}

// MARK: - Motion Manager
actor MotionManager {
    
    static let shared = MotionManager()
    
    private let motionManager: CMMotionManager
    private var referenceAttitude: CMAttitude?
    
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = MotionConstants.queueName
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(motionManager: CMMotionManager = CMMotionManager()) {
        self.motionManager = motionManager
    }
    
    var isMotionAvailable: Bool { motionManager.isDeviceMotionAvailable }
    var isCalibrated: Bool { referenceAttitude != nil }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
        print("[MotionManager] Deallocated")
    }
    
    // MARK: - Public Methods
    
    func calibrate() async throws {
        guard motionManager.isDeviceMotionAvailable else {
            throw MotionError.unavailable
        }
        
        print("[MotionManager] Starting calibration...")
        
        // ✅ FIX 1: Explicit CheckedContinuation<Void, Error> so Swift can infer T = Void
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.motionManager.deviceMotionUpdateInterval = MotionConstants.calibrationInterval
            self.motionManager.startDeviceMotionUpdates(to: self.motionQueue) { motion, error in
                if let error {
                    self.motionManager.stopDeviceMotionUpdates()
                    continuation.resume(throwing: error)
                    return
                }
                guard let motion else {
                    self.motionManager.stopDeviceMotionUpdates()
                    continuation.resume(throwing: MotionError.calibrationFailed)
                    return
                }
                Task {
                    self.referenceAttitude = motion.attitude
                    self.motionManager.stopDeviceMotionUpdates()
                    print("[MotionManager] ✅ Calibration completed")
                    continuation.resume()
                }
            }
        }
    }
    
    func stop() {
        motionQueue.cancelAllOperations()
        motionManager.stopDeviceMotionUpdates()
        referenceAttitude = nil
        print("[MotionManager] 🛑 Motion stopped and reset")
    }
    
    // MARK: - Motion Stream
    func makeMotionStream(
        updateInterval: TimeInterval = MotionConstants.defaultStreamInterval,
        relative: Bool = true
    ) -> AsyncThrowingStream<MotionData, Error> {
        
        // ✅ FIX 2: Pass MotionData.self as first argument so Swift can infer T = MotionData
        return AsyncThrowingStream<MotionData, Error>(
            MotionData.self,
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            
            guard self.motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.unavailable)
                return
            }
            
            self.motionManager.deviceMotionUpdateInterval = updateInterval
            self.motionManager.startDeviceMotionUpdates(
                using: .xArbitraryCorrectedZVertical,
                to: self.motionQueue
            ) { [weak self] motion, error in
                
                guard let self = self else { return }
                
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let motion = motion else {
                    continuation.finish(throwing: MotionError.motionUpdateFailed)
                    return
                }
                
                Task { [weak self] in
                    guard let self = self else { return }
                    
                    let attitudeToUse: CMAttitude = await {
                        if relative, let ref = await self.referenceAttitude {
                            return motion.attitude.relative(to: ref)
                        } else {
                            return motion.attitude
                        }
                    }()
                    
                    let data = MotionData(
                        attitude: attitudeToUse.attitudeQuaternion,
                        gravity: motion.gravity,
                        rotationRate: motion.rotationRate,
                        timestamp: motion.timestamp
                    )
                    continuation.yield(data)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                self.motionManager.stopDeviceMotionUpdates()
                self.motionQueue.cancelAllOperations()
                print("[MotionManager] Stream terminated")
            }
        }
    }
}
