//  MotionViewModel.swift
//  

import Foundation
import CoreMotion

final class MotionViewModel: ObservableObject {
    
    private let motionManager = CMMotionManager()
    private let updateInterval: Double = 1 / 60  // frames per second
    
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    init() {
//        print("updateInterval: \(updateInterval)")
        motionManager.deviceMotionUpdateInterval = updateInterval  
    }
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }
    
    func recalibrate() {
        print("\nrecalibrate()")
        stopUpdates()
        
        // Reset the reference attitude to current orientation
        motionManager.deviceMotion?.attitude
            .multiply(byInverseOf: motionManager.deviceMotion?.attitude ?? CMAttitude())
        
        startUpdates()
    }
    
    func startUpdates() {
        print("startUpdates()")
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device motion not available")
            return
        }
        
        let referenceFrame: CMAttitudeReferenceFrame = .xMagneticNorthZVertical
        
        guard CMMotionManager.availableAttitudeReferenceFrames().contains(referenceFrame) else {
            print("❌ Magnetic North reference frame not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        
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
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        print("stopUpdates()")
    }
}
