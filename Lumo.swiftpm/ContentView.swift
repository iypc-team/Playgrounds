// Lumo  09/17/2025-1
// 

import SwiftUI
//import CoreMotion
//import Foundation
//import Combine

import CoreMotion
import Foundation

import CoreMotion

class MotionManager {
    let motionManager = CMMotionManager()
    
    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                if let attitude = data?.attitude {
                    print("Roll: \(attitude.roll), Pitch: \(attitude.pitch), Yaw: \(attitude.yaw)")
                }
            }
        }
    }
}


/// A thin wrapper that provides an AsyncStream of CMDeviceAttitude values.
final class AttitudeStreamer {
    private let manager = CMMotionManager()
    private let updateInterval: TimeInterval
    
    /// Initialise with the desired sampling interval (seconds).
    init(updateInterval: TimeInterval = 1.0 / 60.0) {   // default ~60 Hz
        self.updateInterval = updateInterval
    }
    
    /// Returns an AsyncStream that yields `CMDeviceAttitude`.
    func attitudeStream() -> AsyncStream<CMMotionManager> {
        // The closure receives a continuation we’ll use to push values.
        AsyncStream { continuation in
            // Ensure the device actually supports attitude (requires device motion).
            guard manager.isDeviceMotionAvailable else {
                continuation.finish()
//                return
            }
            
            // Configure the manager.
            manager.deviceMotionUpdateInterval = updateInterval
            
            // Choose the reference frame you need. `.xArbitraryZVertical` works well for most apps.
            let referenceFrame = CMAttitudeReferenceFrame.xMagneticNorthZVertical
            
            // Start updates on a background queue.
            let queue = OperationQueue()
            queue.name = "AttitudeStreamerQueue"
            queue.maxConcurrentOperationCount = 1
            
            manager.startDeviceMotionUpdates(using: referenceFrame, to: queue) { [weak self] motion, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Propagate the error downstream (optional – you could also just finish).
                    continuation.finish(throwing: error)
                    self.manager.stopDeviceMotionUpdates()
                    return
                }
                
                // Forward the latest attitude if we have one.
                if let attitude = motion?.attitude {
                    continuation.yield(attitude)
                }
            }
            
            // When the consumer stops iterating, clean up.
            continuation.onTermination = { @Sendable _ in
                self.manager.stopDeviceMotionUpdates()
                queue.cancelAllOperations()
            }
        }
    }
}


struct ContentView: View {
    private var attitudeStream = AttitudeStreamer()
    
    var body: some View {
        VStack {
            Text("Pitch: \(attitudeStream.motion.pitch, specifier: "%.3f")")
            Text("Roll:  \(attitudeStream.attitude.roll,  specifier: "%.3f")")
            Text("Yaw:   \(attitudeStream.attitude.yaw,   specifier: "%.3f")")
        }
        .padding()
    }
}
