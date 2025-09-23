import UIKit
import Foundation
// AsyncSequence

let urlString1 = "https://developer.apple.com/"
let urlString2 = "https://developer.apple.com/documentation/coremotion/"

struct DataSequence: AsyncSequence  { 
//    typealias AsyncIterator = Data
    typealias Element = Data
    
    let urls: [URL]
    init(urls: [URL]) {
        self.urls = urls
        print("urls.count: \(self.urls.count)")
    }
    
    func makeAsyncIterator() -> DataIterator {
        return DataIterator(urls: urls)
    }
}

struct DataIterator: AsyncIteratorProtocol  {
    typealias Element = Data
    private var index = 0
    private let urlSession = URLSession.shared
    
    let urls: [URL]
    init(urls: [URL])  {
        self.urls = urls
    }
    
    mutating func next() async throws -> Data? {
        guard index < urls.count else  { // Check bounds
            return nil 
        }
        let url = urls[index] // URL Increment index
        index += 1
        let (data, _) =  try await urlSession.data(from: url) // API Call
        return data
    }
}

class TaskManager  {
    func runTask()  {
        Task  {
            let urlString = "https://developer.apple.com/"
            let urls: [URL] = Array(0...10_000).map {
                _ in URL(string: urlString)}.compactMap({
                    $0
                })
            for try await data in DataSequence(urls: urls) {
                print(data.startIndex)
                print(data.count)
                print(data.endIndex)
            }
        }
    }
    
    let manager = TaskManager()
//    manager.run
}
// Call site (Usage)
//Task  {
//    let urlString = "https://developer.apple.com/"
//    let urls: [URL] = Array(0...10_000).map {
//        _ in URL(string: urlString)}.compactMap({
//            $0
//        })
//    for try await data in DataSequence(urls: urls) {
//        print(data.startIndex)
//        print(data.count)
//        print(data.endIndex)
//    }
//}
