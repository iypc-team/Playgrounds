// 
// 
// Extension on NSOperationQueue to track completed operations

import Foundation

extension OperationQueue {
    
    /// Adds an operation to the queue and calls `completion` when that operation finishes.
    ///
    /// - Parameters:
    ///   - operation: The operation you want to run.
    ///   - completion: A closure executed on the queue’s `underlyingQueue` (or the main queue if none).
    func add(_ operation: Operation,
             didFinish completion: @escaping (Operation) -> Void) {
        
        // Create a wrapper operation that runs after `operation` completes.
        let observer = BlockOperation {
            // This block runs after `operation` finishes.
            completion(operation)
        }
        
        // Ensure the observer runs *after* the original operation.
        observer.addDependency(operation)
        
        // Add both to the queue – order doesn’t matter because of the dependency.
        self.addOperation(operation)
        self.addOperation(observer)
    }
    
    /// Convenience version for a block‑based operation.
    ///
    /// - Parameters:
    ///   - block: The work you want to execute.
    ///   - completion: Called when the block finishes.
    func addOperation(withBlock block: @escaping () -> Void,
                      didFinish completion: @escaping () -> Void) {
        
        let op = BlockOperation(block: block)
        add(op) { _ in completion() }
    }
}

