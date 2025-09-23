//  CoreMotion-3  08/26/2025-1
//  
import SwiftUI
import CoreMotion
import Foundation

struct MotionData {
    let provider = MotionDataProvider.motionProvider
    
//    func stopUpdating() {
//        let description = provider?.deviceMotion?.attitude.description
//        print("stopUpdating()")
//        provider?.stopDeviceMotionUpdates()
//        print("  \(String(describing: description))")
//    }  
}

class MotionDataProvider: ObservableObject {
    static let pr = PrecisionRound()
    typealias mdp = MotionDataProvider
    private let updateInterval: TimeInterval = 1 / 2
    static let motionProvider: CMMotionManager? = CMMotionManager()
    
    @Published var motionActive: Bool = false
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    @Published var w = 0.0
    @Published var roundedX: Double = 0.0
    
    func startMotionUpdates() {
        print("startMotionUpdates()...")
        
        deviceMotionActive()
    }
    
    func stopMotionUpdates() {
        print("stopMotionUpdates()...")
        
        MotionDataProvider.motionProvider?.stopDeviceMotionUpdates()
        deviceMotionActive()
        }
    
    func deviceMotionActive() {
        motionActive = mdp.motionProvider!.isDeviceMotionActive
        print("isDeviceMotionActive: \(String(describing: motionActive))\n")
    }
    
    init() {
        MotionDataProvider.motionProvider?.deviceMotionUpdateInterval = TimeInterval(updateInterval)
        
        mdp.motionProvider?.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] data, error in
            guard let motionAttitude = data?.attitude.quaternion else { return }
            
            self?.x = motionAttitude.x  // .roll
            self?.y = motionAttitude.y  // .pitch
            self?.z = motionAttitude.z  // .yaw
            self?.w = motionAttitude.w  // .wtf
            
        }
        deviceMotionActive()
    }  
}



