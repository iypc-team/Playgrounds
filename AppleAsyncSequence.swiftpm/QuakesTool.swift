// AppleAsyncSequence  09/07/2025-1
// 

import SwiftUI
import Foundation

let iso8601Formatter = DateFormatter()
let endpointURL = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.csv")!

@MainActor
struct QuakesTool {
    static func main() async throws {
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        //        let numbers = [1, 2, 3]
        //        let slowNumbers = SlowAsyncSequence(sequence: numbers)
        //
        //        for try await num in slowNumbers {
        //            print(num * num)
        //        }
        
//                let (bytes, _) = try await URLSession.shared.bytes(from: endpointURL, delegate: nil)
//                for try await byte in bytes {
//                    print(UInt8(byte))
//                }
        
        let quakes = endpointURL.lines.dropFirst().compactMap { line in
            Quake.parse(line, formatter: iso8601Formatter)
        }
        for try await quake in quakes where quake.magnitude > 3 {
            print(quake)
        }
    }
}

func myFor<S: Sequence>(_ sequence: S, _ block: (S.Element) -> Void) {
    var iterator = sequence.makeIterator()
    while let value = iterator.next() {
        block(value)
    }
}

struct SlowAsyncSequence<S: Sequence>: AsyncSequence {
    typealias Element = S.Element
    
    let sequence: S
    
    func makeAsyncIterator() -> SlowAsyncIterator<S.Iterator> {
        SlowAsyncIterator(iterator: sequence.makeIterator())
    }
    
    struct SlowAsyncIterator<I: IteratorProtocol>: AsyncIteratorProtocol {
        typealias Element = I.Element
        
        var iterator: I
        
        mutating func next() async throws -> Element? {
            if let value = iterator.next() {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                return value
            }
            return nil
        }
    }
}


struct Quake {
    let time: Date
    let latitude: Double
    let longitude: Double
    let magnitude: Double
    
    static func parse(_ line: String, formatter: DateFormatter) -> Quake? {
        let values = line.split(separator: ",")
        guard values.count > 4 else { return nil }
        
        guard let time = formatter.date(from: String(values[0])),
              let latitude = Double(values[1]),
              let longitude = Double(values[2]),
              let magnitude = Double(values[4]) else {
            return nil
        }
        
        return .init(time: time, latitude: latitude, longitude: longitude, magnitude: magnitude)
    }
}

class QuakeMonitor: ObservableObject  {
    @Published var quakeHandler: (Quake) -> Void
    
    init()  {
        
        Task  {
            print("Start Task...")
//            await fetchData()
            print("Completed Task")
        }
    }
    
    func startMonitoring() {
        
    }
    func stopMonitoring()  {
        
    }
}



