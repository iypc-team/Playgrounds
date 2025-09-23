//
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

//final class MotionServiceAdater: MotionService {
class MotionServiceAdater: MotionService {
    static let shared = MotionServiceAdater()
    static let motionManager = CMMotionManager()
 //   private let motionManager = CMMotionManager()
    static var streamContinuation: AsyncStream<(Double, Double)>.Continuation?
 //   private var streamContinuation: AsyncStream<(Double, Double)>.Continuation?
    
//    private init() { }
    init() { }
    
    func getStream() -> AsyncStream<(Double, Double)> {
        return AsyncStream<(Double, Double)> { continuation in
            continuation.onTermination = { @Sendable [weak self] _ in self?.stopMonitoring() }
            MotionServiceAdater.streamContinuation = continuation
            Task.detached { [weak self] in
                self?.startMonitoring(with: continuation)
            }
        }
    }
    
    func stopStream() {
        MotionServiceAdater.streamContinuation?.finish()
        MotionServiceAdater.streamContinuation = nil
    }
    
//    private func startMonitoring(with continuation: AsyncStream<(Double, Double)>.Continuation) {
    func startMonitoring(with continuation: AsyncStream<(Double, Double)>.Continuation) {
        guard
            MotionServiceAdater.motionManager.isDeviceMotionAvailable,
            !MotionServiceAdater.motionManager.isDeviceMotionActive
        else { return }
        MotionServiceAdater.motionManager.startDeviceMotionUpdates(to: OperationQueue()) { motion, error in
            guard
                error == nil,
                let gravity = motion?.gravity
            else { return }
            continuation.yield((gravity.x, gravity.y))
            print("Gravity -----> (\(gravity.x), \(gravity.y), \(gravity.z) )")
        }
    }
    
//    private func stopMonitoring() {
    func stopMonitoring() {
        guard
            MotionServiceAdater.motionManager.isDeviceMotionAvailable,
            MotionServiceAdater.motionManager.isDeviceMotionActive
        else { return }
        MotionServiceAdater.motionManager.stopDeviceMotionUpdates()
    }
}

