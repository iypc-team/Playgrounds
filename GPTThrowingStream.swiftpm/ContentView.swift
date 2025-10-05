// GPTThrowingStream  10/05/2025-2
// CoreMotion attitude quaternion AsyncThrowingStream
// 

import SwiftUI
import CoreMotion

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, nucklehead!")
        }
        .font(.title)
    }
}

import CoreMotion
import Foundation

// Function to get the motion attitude as a stream
func getAttitudeStream() -> AsyncThrowingStream<CMQuaternion, Error> {
    AsyncThrowingStream { continuation in
        // Set up CMMotionManager
        let motionManager = CMMotionManager()
        
        // Check if the device supports attitude updates
        guard motionManager.isDeviceMotionAvailable else {
            continuation.finish(throwing: NSError(domain: "MotionManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion is not available"]))
            return
        }
        
        // Start receiving device motion data
        motionManager.deviceMotionUpdateInterval = 1 / 60.0 // Update every 1/60 seconds (60Hz)
        
        motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            if let error = error {
                continuation.finish(throwing: error)
                return
            }
            
            // Retrieve the quaternion from the device motion
            if let motion = motionData {
                let quaternion = motion.attitude.quaternion
                continuation.yield(quaternion)
            }
        }
        
        // Ensure to stop motion updates when the stream finishes
        continuation.onTermination = { _ in
            motionManager.stopDeviceMotionUpdates()
        }
    }
}

// Usage: Calling the async stream and handling the values
Task {
    do {
        let attitudeStream = getAttitudeStream()
        for try await quaternion in attitudeStream {
            // Process quaternion data here
            print("Quaternion: \(quaternion)")
        }
    } catch {
        print("Error receiving attitude data: \(error)")
    }
}
