// MotionManager.swift
// Production-ready motion tracking with Magnetic North orientation support.

import CoreMotion

// MARK: - Constants
private enum MotionConstants {
    static let calibrationInterval: TimeInterval = 0.1
    static let defaultStreamInterval: TimeInterval = 1.0 / 60.0
    static let queueName: String = "com.iypc-team.motionQueue"
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
struct AttitudeQuaternion: Sendable {
    let quaternion: CMQuaternion
    let roll: Double
    let pitch: Double
    let yaw: Double  // 0° = Magnetic North when using north reference frame
    
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

struct MotionData: Sendable {
    let attitude: AttitudeQuaternion
    let gravity: CMAcceleration
    let rotationRate: CMRotationRate
    let magneticField: CMCalibratedMagneticField?  // Added for debugging interference
    let timestamp: TimeInterval
    let isNorthAligned: Bool
}

// MARK: - Motion Errors
enum MotionError: Error, LocalizedError {
    case unavailable
    case motionUpdateFailed
    case calibrationFailed
    case magneticInterference
    
    var errorDescription: String? {
        switch self {
        case .unavailable:          return "Device motion is not available"
        case .motionUpdateFailed:   return "Motion update failed"
        case .calibrationFailed:    return "Failed to calibrate motion sensor"
        case .magneticInterference: return "Strong magnetic interference detected. Move away from metal/magnets and recalibrate."
        }
    }
}

// MARK: - Motion Manager
actor MotionManager {
    
    static let shared = MotionManager()
    
    private let motionManager: CMMotionManager
    private var referenceAttitude: CMAttitude?
    private var isUsingMagneticNorth: Bool = true  // Default: align to magnetic north
    
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = MotionConstants.queueName
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(motionManager: CMMotionManager = CMMotionManager()) {
        self.motionManager = motionManager
        self.motionManager.showsDeviceMovementDisplay = true  // Shows calibration HUD if needed
    }
    
    var isMotionAvailable: Bool { motionManager.isDeviceMotionAvailable }
    var isCalibrated: Bool { referenceAttitude != nil }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
        print("[MotionManager] Deallocated")
    }
    
    // MARK: - Public Methods
    
    /// Calibrates and aligns the device to **magnetic north** (recommended for compass/orientation apps)
    func calibrateToMagneticNorth() async throws {
        isUsingMagneticNorth = true
        try await calibrateInternal(referenceFrame: .xMagneticNorthZVertical)
    }
    
    /// Legacy relative calibration (user-defined zero point)
    func calibrate() async throws {
        isUsingMagneticNorth = false
        try await calibrateInternal(referenceFrame: .xArbitraryCorrectedZVertical)
    }
    
    private func calibrateInternal(referenceFrame: CMAttitudeReferenceFrame) async throws {
        guard isMotionAvailable else {
            throw MotionError.unavailable
        }
        
        print("[MotionManager] Starting calibration to \(referenceFrame)...")
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            motionManager.deviceMotionUpdateInterval = MotionConstants.calibrationInterval
            motionManager.startDeviceMotionUpdates(using: referenceFrame, to: motionQueue) { motion, error in
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
                
                self.referenceAttitude = motion.attitude
                self.motionManager.stopDeviceMotionUpdates()
                print("[MotionManager] ✅ Calibration completed (\(referenceFrame))")
                continuation.resume()
            }
        }
    }
    
    func stop() {
        motionQueue.cancelAllOperations()
        motionManager.stopDeviceMotionUpdates()
        referenceAttitude = nil
        print("[MotionManager] 🛑 Motion stopped")
    }
    
    // MARK: - Motion Stream
    func makeMotionStream(
        updateInterval: TimeInterval = MotionConstants.defaultStreamInterval,
        relative: Bool = false  // When true + magnetic north, yaw stays aligned to north
    ) -> AsyncThrowingStream<MotionData, Error> {
        
        return AsyncThrowingStream<MotionData, Error>(
            MotionData.self,
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            
            guard self.isMotionAvailable else {
                continuation.finish(throwing: MotionError.unavailable)
                return
            }
            
            let referenceFrame: CMAttitudeReferenceFrame = self.isUsingMagneticNorth 
            ? .xMagneticNorthZVertical 
            : .xArbitraryCorrectedZVertical
            
            self.motionManager.deviceMotionUpdateInterval = updateInterval
            self.motionManager.startDeviceMotionUpdates(
                using: referenceFrame,
                to: self.motionQueue
            ) { motion, error in
                
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
                        magneticField: motion.magneticField,
                        timestamp: motion.timestamp,
                        isNorthAligned: self.isUsingMagneticNorth
                    )
                    
                    // Optional: Warn on poor magnetic accuracy
                    // 
                    if let field = motion.magneticField, field.accuracy == .uncertain {
                        print("[MotionManager] ⚠️ Magnetic field uncertain")
                    }
                    
                    continuation.yield(data)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                self.motionManager.stopDeviceMotionUpdates()
                print("[MotionManager] Stream terminated")
            }
        }
    }
}
