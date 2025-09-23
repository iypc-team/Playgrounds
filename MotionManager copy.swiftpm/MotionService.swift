////
////  MotionService.swift
////  MotionService
////
////  Created by Tomas Trujillo on 2021-08-08.
////
//
//import Foundation
//import CoreMotion
//
//protocol MotionService {
//    func getStream() -> AsyncStream<(Double, Double, Double)>
//    func stopStream()
//}
//
//final class MotionServiceAdater: MotionService {
//    static let shared = MotionServiceAdater()
//    private let motionManager = CMMotionManager()
//    private var streamContinuation: AsyncStream<(Double, Double, Double)>.Continuation?
//    
//    private init() { }
//    
//    func getStream() -> AsyncStream<(Double, Double, Double)> {
//        return AsyncStream<(Double, Double, Double)> { continuation in
//            continuation.onTermination = { @Sendable [weak self] _ in self?.stopMonitoring() }
//            self.streamContinuation = continuation
//            Task.detached { [weak self] in
//                self?.startMonitoring(with: continuation)
//            }
//        }
//    }
//    
//    func stopStream() {
//        streamContinuation?.finish()
//        streamContinuation = nil
//    }
//    
//    private func startMonitoring(with continuation: AsyncStream<(Double, Double, Double)>.Continuation) {
//        guard
//            motionManager.isDeviceMotionAvailable,
//            !motionManager.isDeviceMotionActive
//        else { return }
//        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { motion, error in
//            guard
//                error == nil,
//                let attitude = motion?.attitude.quaternion
//            else { return }
//            continuation.yield((attitude.x, attitude.y, attitude.z))
//            print("attitude -----> (\(attitude.x), \(attitude.y), \(attitude.z) )")
//        }
//    }
//    
//    private func stopMonitoring() {
//        guard
//            motionManager.isDeviceMotionAvailable,
//            motionManager.isDeviceMotionActive
//        else { return }
//        motionManager.stopDeviceMotionUpdates()
//    }
//}
//
