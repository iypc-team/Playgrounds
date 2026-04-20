//  MotionViewModel.swift
//

import Foundation
import CoreMotion
import Combine
import simd

// MARK: – MotionSample abstraction

/// Minimal protocol exposing a SIMD quaternion representation of a motion sample.
protocol MotionSample {
    var simdQuaternion: simd_quatd { get }
}

/// Makes `CMDeviceMotion` conform to `MotionSample`.
extension CMDeviceMotion: MotionSample {
    
    @inline(__always)
    var simdQuaternion: simd_quatd {
        let q = attitude.quaternion
        guard q.x.isFinite, q.y.isFinite, q.z.isFinite, q.w.isFinite else {
            // Why: guarantees a valid unit quaternion even on sensor corruption
            return simd_quatd(ix: 0, iy: 0, iz: 0, r: 1)
        }
        
        return simd_quatd(ix: q.x, iy: q.y, iz: q.z, r: q.w).normalized
    }
}

// MARK: – Motion stream provider

/// Supplies an `AsyncStream` of `MotionSample`s using CoreMotion.
final class MotionStreamProvider {
    
    private let manager = CMMotionManager()
    private let interval: TimeInterval = 1.0 / 60.0   // Nominal 60 Hz
    
    /// Serial queue for CoreMotion callbacks.
    private let motionQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "MotionStreamProvider.CoreMotionQueue"
        q.qualityOfService = .userInitiated
        q.maxConcurrentOperationCount = 1              // Preserve order
        return q
    }()
    
    deinit {
        // Defensive cleanup if the provider is released unexpectedly.
        manager.stopDeviceMotionUpdates()
        motionQueue.cancelAllOperations()
    }
    
    /// Returns an `AsyncStream` that yields `MotionSample`s.
    /// The stream finishes automatically when device motion is unavailable
    /// or when the consumer cancels the continuation.
    func stream() -> AsyncStream<MotionSample> {
        AsyncStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish()
                return
            }
            
            // Ensure the queue is active in case a prior stream was stopped.
            motionQueue.isSuspended = false
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(
                using: .xArbitraryZVertical,
                to: motionQueue
            ) { motion, _ in
                if let motion {
                    continuation.yield(motion)        // Bridge to consumer
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                // Ensure no further callbacks are delivered.
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}

// MARK: – Motion view model

/// Publishes device orientation data for SwiftUI views.
@MainActor
final class MotionViewModel: ObservableObject {
    
    // MARK: Published UI values (degrees / matrix)
    
    @Published private(set) var roll: Double = 0
    @Published private(set) var pitch: Double = 0
    @Published private(set) var yaw: Double = 0
    @Published private(set) var rotationMatrix = matrix_identity_double3x3
    @Published private(set) var isStreaming = false
    
    // MARK: Raw quaternion publisher (read-only)
    
    private let motionSubject = PassthroughSubject<simd_quatd, Never>()
    var motionPublisher: AnyPublisher<simd_quatd, Never> {
        motionSubject.eraseToAnyPublisher()
    }
    
    // MARK: Internal state
    
    private let provider = MotionStreamProvider()
    private var streamingTask: Task<Void, Never>?
    
    private var referenceQuat: simd_quatd?           // Current reference frame
    private var filteredQuat: simd_quatd?            // Smoothed orientation
    private var lastRawQuat: simd_quatd?             // Most recent raw sample
    private var lastAngularVelocity: Double = 0      // For jerk calculation
    
    private let updateInterval = 1.0 / 60.0          // Seconds per frame
    
    // MARK: Constants (tuned for 60 Hz)
    
    private enum Constants {
        static let deadZoneOmega      = 0.02
        static let minAlpha           = 0.04
        static let maxAlpha           = 0.40
        static let jerkGain           = 0.35
        static let convergenceEpsilon = 0.01
        static let maxJerk            = 1_000.0
    }
    
    // MARK: – Lifecycle
    
    /// Starts the motion stream. Subsequent calls are ignored until `stopStream()` is invoked.
    func startStream() {
        guard streamingTask == nil else { return }
        
        isStreaming = true
        streamingTask = Task {
            for await sample in provider.stream() {
                process(sample: sample)
            }
            
            // If the stream ends unexpectedly, keep the state consistent.
            await MainActor.run {
                self.streamingTask = nil
                self.isStreaming = false
            }
        }
    }
    
    /// Stops the stream and clears all internal state.
    func stopStream() async {
        guard let task = streamingTask else { return }
        
        task.cancel()
        // Await termination to avoid a race where the cancelled task writes stale data.
        await task.value
        streamingTask = nil
        isStreaming = false
        
        filteredQuat = nil
        lastRawQuat = nil
        lastAngularVelocity = 0
        referenceQuat = nil
    }
    
    /// Re-bases the orientation reference to the most stable recent sample.
    ///
    /// - Returns: `true` if a new reference was installed, `false` otherwise.
    @discardableResult
    func recalibrate() -> Bool {
        // Prefer the raw quaternion; fall back to the filtered one.
        let newReference: simd_quatd
        if let raw = lastRawQuat {
            newReference = raw.normalized
        } else if let filtered = filteredQuat {
            newReference = filtered.normalized
        } else {
            referenceQuat = nil
            return false
        }
        
        let inv = newReference.inverse
        
        // Re-base filtered and raw quaternions to preserve continuity.
        if let filtered = filteredQuat {
            filteredQuat = (filtered * inv).normalized
        }
        if let raw = lastRawQuat {
            lastRawQuat = (raw * inv).normalized
        }
        
        referenceQuat = newReference
        
        // Immediately publish the recalibrated orientation so the UI updates now.
        if let filteredQuat {
            publish(filteredQuat)
        }
        
        // Intentionally do **not** reset `lastAngularVelocity` – this keeps
        // jerk-based smoothing stable across the transition.
        return true
    }
    
    // MARK: – Processing pipeline
    
    private func process(sample: MotionSample) {
        // Normalise the incoming quaternion (defensive safety).
        let currentQuat = sample.simdQuaternion.normalized
        
        // Apply the current reference frame, if any.
        let relativeQuat = referenceQuat.map { currentQuat * $0.inverse } ?? currentQuat
        
        // First sample – initialise state.
        guard let previous = lastRawQuat else {
            filteredQuat = relativeQuat
            lastRawQuat = relativeQuat
            publish(relativeQuat)
            return
        }
        
        // --------------------------------------------------------------
        // Angular velocity & jerk computation
        // --------------------------------------------------------------
        let omega = angularVelocity(from: previous, to: relativeQuat)
        
        // Guard against non-finite results (sensor glitches).
        guard omega.isFinite else {
            return
        }
        
        let jerk = min(
            abs(omega - lastAngularVelocity) / updateInterval,
            Constants.maxJerk
        )
        lastAngularVelocity = omega
        
        // --------------------------------------------------------------
        // Adaptive smoothing
        // --------------------------------------------------------------
        if omega < Constants.deadZoneOmega {
            // Very slow motion – converge quickly.
            filteredQuat = simd_slerp(
                filteredQuat ?? relativeQuat,
                relativeQuat,
                Constants.convergenceEpsilon
            )
        } else {
            // Faster motion – adapt smoothing based on jerk.
            let alpha = min(
                Constants.maxAlpha,
                max(
                    Constants.minAlpha,
                    Constants.minAlpha + Constants.jerkGain * jerk
                )
            )
            filteredQuat = simd_slerp(
                filteredQuat ?? relativeQuat,
                relativeQuat,
                alpha
            )
        }
        
        // --------------------------------------------------------------
        // Publish the new orientation.
        // --------------------------------------------------------------
        lastRawQuat = relativeQuat
        if let fq = filteredQuat {
            publish(fq)
        }
    }
    
    // MARK: – Publishing
    
    private func publish(_ quat: simd_quatd) {
        // Update the rotation matrix.
        rotationMatrix = simd_double3x3(quat)
        
        // Convert quaternion → Euler angles (radians → degrees).
        let e = quat.eulerAngles
        let newPitch = radiansToDegrees(e.x)
        let newYaw   = wrapDegrees(radiansToDegrees(e.y))
        let newRoll  = radiansToDegrees(e.z)
        
        // Assign only when the value actually changes – reduces UI churn.
        if pitch != newPitch { pitch = newPitch }
        if yaw   != newYaw   { yaw   = newYaw }
        if roll  != newRoll  { roll  = newRoll }
        
        // Forward the raw quaternion to any external subscribers.
        motionSubject.send(quat)
    }
    
    // MARK: – Math helpers
    
    /// Computes angular velocity (rad / s) between two unit quaternions.
    private func angularVelocity(from q1: simd_quatd, to q2: simd_quatd) -> Double {
        let dot = simd_dot(q1.vector, q2.vector)
        // Clamp to [-1, 1] and guard against NaN.
        let clamped = min(1.0, max(-1.0, dot))
        guard clamped.isFinite else { return 0 }
        let angle = 2.0 * acos(abs(clamped))          // Shortest-arc angle
        return angle / updateInterval
    }
    
    @inline(__always)
    private func radiansToDegrees(_ r: Double) -> Double {
        r * 180.0 / .pi
    }
    
    /// Normalises a degree value to the range (-180°, +180°].
    @inline(__always)
    private func wrapDegrees(_ d: Double) -> Double {
        var x = d.truncatingRemainder(dividingBy: 360.0)
        if x > 180.0 { x -= 360.0 }
        if x < -180.0 { x += 360.0 }
        return x
    }
}

// MARK: – Quaternion → Euler (right-handed, pitch-yaw-roll order)

private extension simd_quatd {
    /// Returns the Euler angles (pitch, yaw, roll) in radians.
    var eulerAngles: SIMD3<Double> {
        // Normalise to avoid drift-induced scaling errors.
        let q = normalized
        let sinp = 2.0 * (q.real * q.imag.x - q.imag.y * q.imag.z)
        let pitch = abs(sinp) >= 1.0
        ? copysign(.pi / 2.0, sinp)   // Gimbal lock
        : asin(sinp)
        
        let yaw = atan2(
            2.0 * (q.real * q.imag.y + q.imag.z * q.imag.x),
            1.0 - 2.0 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        )
        
        let roll = atan2(
            2.0 * (q.real * q.imag.z + q.imag.x * q.imag.y),
            1.0 - 2.0 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        )
        
        return SIMD3(pitch, yaw, roll)
    }
}
