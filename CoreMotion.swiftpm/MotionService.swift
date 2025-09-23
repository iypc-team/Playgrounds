//  CoreMotion 09/05/2025-1
//  MotionService.swift
//  MotionService
//  https://raw.githubusercontent.com/codingWithTom/WWDC21-SwiftUI/FourthVideo/WWDC21/Services/MotionService.swift
//  Created by Tomas Trujillo on 2021-08-08.
//

import Foundation
import CoreMotion

protocol MotionService {
    func getStream() -> AsyncStream<(Double, Double)>
    func stopStream()
}

final class MotionServiceAdater: MotionService {
    static let shared = MotionServiceAdater()
    private let updateInterval: TimeInterval = 3
    private let motionManager = CMMotionManager()
    private var streamContinuation: AsyncStream<(Double, Double)>.Continuation?
    
    private init() { }
    
    func getStream() -> AsyncStream<(Double, Double )> {
        return AsyncStream<(Double, Double )> { continuation in
            continuation.onTermination = { @Sendable [weak self] _ in self?.stopMonitoring() }
            self.streamContinuation = continuation
            Task.detached { [weak self] in
                self?.startMonitoring(with: continuation)
            }
        }
    }
    
    func stopStream() {
        streamContinuation?.finish()
        streamContinuation = nil
    }
    
    public func startMonitoring(with continuation: AsyncStream<(Double, Double)>.Continuation) {
        guard
            motionManager.isDeviceMotionAvailable,
            !motionManager.isDeviceMotionActive
        else { return }
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { motion, error in
            guard
                error == nil,
                let attitude = motion?.attitude.quaternion
            else { return }
            continuation.yield((attitude.x, attitude.y))
            print("Attitude: (\(attitude.x), \(attitude.y), \(attitude.z) )")
        }
    }
    
    public func stopMonitoring() {
        guard
            motionManager.isDeviceMotionAvailable,
            motionManager.isDeviceMotionActive
        else { return }
        motionManager.stopDeviceMotionUpdates()
    }
}



