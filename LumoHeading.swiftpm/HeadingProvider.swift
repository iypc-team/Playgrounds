// 
// 
// 

import CoreLocation
import Combine   // only needed if you also want a Combine publisher

// MARK: – Heading provider that wraps CLLocationManager in an AsyncStream
final class HeadingProvider: NSObject {
    public let locationManager = CLLocationManager()
    public var continuation: AsyncStream<CLHeading>.Continuation?
    public var isPaused = false
    
    override init() {
        print("HeadingProvider")
        print("init()")
        super.init()
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.delegate?.locationManagerShouldDisplayHeadingCalibration!(CLLocationManager.init())
        // Request permission – adjust as needed for your app’s UI flow
//        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: Public API
    
    /// Returns an AsyncStream that yields fresh `CLHeading` values.
    func headingStream() -> AsyncStream<CLHeading> {
        print("func headingStream()")
        return AsyncStream { [weak self] cont in
            guard let self = self else { return }
            self.continuation = cont
            
            // Start delivering headings
            self.locationManager.startUpdatingHeading()
            
            // When the consumer finishes/cancels the stream
            cont.onTermination = { @Sendable _ in
                self.stop()
            }
        }
    }
    
    /// Pause delivery of new heading values.
    func pause() {
        print("func pause()")
        print("isPaused: \(isPaused)")
        isPaused.toggle()
        print("isPaused: \(isPaused)")
    }
    
    /// Resume delivery after a pause.
    func resume() {
        print("func resume()")
        guard isPaused else { return }
        isPaused = false
    }
    
    /// Completely stop the manager and close the stream.
    func stop() {
        print("func stop()")
        locationManager.stopUpdatingHeading()
        continuation?.finish()
        continuation = nil
    }
}

// MARK: – CLLocationManagerDelegate
extension HeadingProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading) {
        print("locationManager.didUpdateHeading")
        // If we’re paused, just ignore the update.
        guard !isPaused else { return }
        continuation?.yield(newHeading)
    }
    
    // Optional: handle errors / calibration prompts
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("locationManager.didFailWithError")
        print("Error: \(error.localizedDescription)")
        continuation?.finish()
        
        func locationManager(_ manager: CLLocationManager,
                             didUpdateHeading heading: CLHeading) {
            // Use heading.magneticHeading, heading.trueHeading, etc.
        }
        
        func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
            // Return true if you want to give the user a chance to calibrate now.
            // Often you return false and let iOS decide automatically.
            // return false
            return true
        }
    }
}

//
