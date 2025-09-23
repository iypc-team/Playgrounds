//  QuaternionMotion  09/01/2025-2
//  
import SwiftUI
import CoreMotion
import Foundation

struct MotionData {
    let provider = MotionDataProvider.motionProvider
    
    //    public func stopUpdating() {
    //        let description = provider?.deviceMotion?.attitude.description
    //        print("stopUpdating()")
    //        provider?.stopDeviceMotionUpdates()
    //        print("  \(String(describing: description))")
    //    }  
}

class MotionDataProvider: ObservableObject {
    static let pr = PrecisionRound()
    typealias mdp = MotionDataProvider
    private let updateInterval: TimeInterval = 1
    static let motionProvider: CMMotionManager? = CMMotionManager()
    static let deviceMotion: CMDeviceMotion? = CMDeviceMotion()
    
    @Published var motionActive: Bool = false
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    @Published var w = 0.0
    @Published var heading = 0.0
    
    func startMotionUpdates() {
        print("startMotionUpdates()...")
        
        deviceMotionActive()
    }
    
    public func stopMotionUpdates() {
        print("stopMotionUpdates()...")
        
        MotionDataProvider.motionProvider?.stopDeviceMotionUpdates()
        deviceMotionActive()
    }
    
    public func deviceMotionActive() {
        motionActive = mdp.motionProvider!.isDeviceMotionActive
        print("isDeviceMotionActive: \(String(describing: motionActive))\n")
    }
    
    public func degreesFromRadians(radians: Double) -> Double {
        // degrees = radians x 180°/π
        let degrees = radians * 180 / .pi 
        return degrees
    }
    
    init() {
        MotionDataProvider.motionProvider?.deviceMotionUpdateInterval = TimeInterval(updateInterval)
        
        mdp.motionProvider?.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] data, error in
            guard let motionAttitude = data?.attitude.quaternion else { return }
            
            self?.x = motionAttitude.x  // .roll
            self?.y = motionAttitude.y  // .pitch
            self?.z = motionAttitude.z  // .yaw
            self?.w = motionAttitude.w  // .wtf
            
            print("DATA:\n\(data!)\n")
        }
        
    }  
}



//
