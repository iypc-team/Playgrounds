// MotionService
// 

import CoreMotion
import Foundation

enum MotionError: Error {
    case unavailable
    case failed(Error)
}

enum CMMagneticFieldCalibrationAccuracy : Int {
    case uncalibrated = -1
    case low = 0
    case medium = 1
    case high = 2
}

extension OperationQueue {
    // Lumo Extension NSOperationQueue running count total
    /// Returns the number of operations that are currently executing.
    var runningCount: Int {
        // `operations` contains all queued operations (executing, pending, finished).
        // We only count those where `isExecuting` is true.
        return operations.filter { $0.isExecuting }.count
    }
    
    /// Returns the total number of operations ever added to the queue,
    /// including those that have already finished.
    var totalAddedCount: Int {
        // `operationCount` reflects only the *current* number of operations
        // (executing + pending). To keep a running total you need to track it yourself.
        // One simple approach is to increment a counter each time you add an operation.
        return _totalAddedCount
    }
    
    // MARK: – Private bookkeeping
    
    private static var totalKey = "Lumo_OperationQueue_TotalAdded"
    
    private var _totalAddedCount: Int {
        get {
            // Store the count in the queue’s associated object dictionary.
            // This persists for the lifetime of the queue instance.
            return objc_getAssociatedObject(self, &Self.totalKey) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &Self.totalKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Override `addOperation(_:)` to update the total‑added counter.
    public override func addOperation(_ op: Operation) {
        // Increment our total before delegating to the superclass implementation.
        _totalAddedCount += 1
        super.addOperation(op)
    }
}

extension OperationQueue {
    /// Returns the number of operations that are still waiting to be executed.
    var waitingCount: Int {
        // `operations` gives you all operations that are either executing,
        // pending, or have finished but haven’t been removed yet.
        // Filtering out the ones that are already finished gives a true “queue length”.
        return operations.filter { !$0.isFinished }.count
    }
    var count: Int {
        // `operations` gives you all operations that are either executing,
        // pending, or have finished but haven’t been removed yet.
        // Filtering out the ones that are already finished gives a true “queue length”.
        return operations.filter { $0.isFinished }.count
    }
}

final class MotionService {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    init() {
        queue.name = "MotionQueue"
        queue.maxConcurrentOperationCount = 8
        queue.qualityOfService = .background
        print("\(queue.debugDescription)")
    }
    
    func deviceCalibration() {
        if let deviceMotion = manager.deviceMotion {
            let magAccuracy = deviceMotion.magneticField.accuracy
            switch magAccuracy {
            case .high:
                print("High magnetic field accuracy")
            case .medium:
                print("Medium magnetic field accuracy")
            case .low:
                print("Low magnetic field accuracy")
            case .uncalibrated:
                print("Uncalibrated magnetic field")
            @unknown default:
                print("Unknown accuracy")
            }
        }
    }
    
    // MARK: Public API
    /// Async stream of quaternions expressed in the xMagneticNorthZVertical reference frame.
    func quaternionStream(
        updateInterval: TimeInterval = 1.0 / 60.0   // 60 Hz by default
    ) -> AsyncThrowingStream<CMQuaternion, Error> {
        
        AsyncThrowingStream { continuation in
            guard manager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionError.unavailable)
                return
            }
            
            manager.deviceMotionUpdateInterval = updateInterval
            
            // Choose the reference frame you asked for:
            // .xMagneticNorthZVertical aligns X→magnetic north, Z→vertical.
            manager.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical,
                to: queue
            ) { [weak self] motion, error in
                guard let self = self else { return }
                
                if let error = error {
                    continuation.finish(throwing: MotionError.failed(error))
                    self.manager.stopDeviceMotionUpdates()
                    return
                }
                
                guard let quat = motion?.attitude.quaternion else { return }
                print("\(quat)\n")
                print("waitingCount: \(queue.waitingCount)")
                print("count: \(queue.count)")
                continuation.yield(quat)
            }
            
            // Clean‑up when the consumer cancels the stream:
            continuation.onTermination = { @Sendable _ in
                self.manager.stopDeviceMotionUpdates()
            }
        }
    }
}


