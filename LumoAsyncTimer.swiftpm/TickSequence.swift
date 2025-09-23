// LumoAsyncTimer  09/05/2025-1
// 

import Foundation

struct TickSequence: AsyncSequence {
    typealias Element = Date
    
    let interval: TimeInterval
    let maxTicks: Int
    
    func makeAsyncIterator() -> Iterator {
        Iterator(interval: interval, remaining: maxTicks)
    }
    
    struct Iterator: AsyncIteratorProtocol {
        let interval: TimeInterval
        var remaining: Int
        
        mutating func next() async throws -> Date? {
            guard remaining > 0 else { return nil }          // end of sequence
            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            remaining -= 1
            return Date()
        }
    }
}

