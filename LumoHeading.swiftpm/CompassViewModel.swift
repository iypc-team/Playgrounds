// 
// 
// 
import SwiftUI
import CoreLocation

@MainActor
final class CompassViewModel: ObservableObject {
    @Published var yaw = 0.0
    @Published var heading: Double = 0.0   // magnetic heading in degrees
    public var provider = HeadingProvider()
    public var task: Task<Void, Never>?   // keep a reference to cancel later
    
    
    
    init() {
        print("init()")
        self.task = Task {
            // `for await` iterates over each heading as it arrives.
            for await newHeading in provider.headingStream() {
                // Update UI on the main actor.
                heading = newHeading.trueHeading
                print("timestamp: \(newHeading.timestamp.description)")
                print("trueHeading:  \(newHeading.trueHeading)")
                print("magneticHeading:  \(newHeading.magneticHeading)\n")
                
            }
        }
    }
    
    deinit {
        task?.cancel()
    }
}

