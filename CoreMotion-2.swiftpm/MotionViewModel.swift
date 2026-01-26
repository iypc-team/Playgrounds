//  MotionViewModel.swift
//  

import Foundation
import CoreMotion

final class MotionViewModel: ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 0.5 / 20
    }
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }
    
    func recalibrate() {
        stopUpdates()
        
        // Reset the reference attitude to current orientation
        motionManager.deviceMotion?.attitude.multiply(byInverseOf: motionManager.deviceMotion?.attitude ?? CMAttitude())
        
        startUpdates()
    }
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device motion not available")
            return
        }
        
        let referenceFrame: CMAttitudeReferenceFrame = .xMagneticNorthZVertical
        
        guard CMMotionManager.availableAttitudeReferenceFrames().contains(referenceFrame) else {
            print("❌ Magnetic North reference frame not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        
        motionManager.startDeviceMotionUpdates(using: referenceFrame, to: .main) { [weak self] data, error in
            guard let self,
                  let attitude = data?.attitude,
                  error == nil else { return }
            
            // Radians → Degrees (optional but recommended)
            self.roll  = attitude.roll  * 180 / .pi
            self.pitch = attitude.pitch * 180 / .pi
            self.yaw   = attitude.yaw   * 180 / .pi
        }
    }
    
//    func startUpdates() {
//        guard motionManager.isDeviceMotionAvailable else {
//            print("❌ Device motion not available")
//            return
//        }
//        
//        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
//            guard let self,
//                  let attitude = data?.attitude,
//                  error == nil else { return }
//            
//            self.roll = attitude.roll
//            self.pitch = attitude.pitch
//            self.yaw = attitude.yaw
//        }
//    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
