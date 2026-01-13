// 
// 
//  print

import SwiftUI

struct FrameworkClass: Identifiable, Hashable, Decodable {
    var id: String { name }
    let name: String
    let methods: [String]
}

private struct MethodsPayload: Decodable {
    let frameworks: [String: [FrameworkClass]]
    // JSON shape:
    // {
    //   "frameworks": {
    //     "RealityKit": [ { "name": "Entity", "methods": ["move(to:)", ...] } ],
    //     "UIKit":     [ { "name": "UIView", "methods": ["init(frame:)", ...] } ]
    //   }
    // }
}

class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    @Published var classMethods: [FrameworkClass] = []
    let framework: Framework
    
    init(framework: Framework) {
        self.framework = framework
        fetchMethods()
        classMethods = fetchClassesAndFunctions(for: framework.name)
        printMethods()
    }
    
    func printMethods()  {
        print("classMethods: \(self.classMethods)")
        print("methods: \(self.methods)")
    }
    
    func fetchMethods() {
        // existing method loading…
    }
    
    func fetchClassesAndFunctions(for frameworkName: String) -> [FrameworkClass] {
        guard
            let url = Bundle.main.url(forResource: "methods", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let payload = try? JSONDecoder().decode(MethodsPayload.self, from: data)
        else {
            return []
        }
        return payload.frameworks[frameworkName] ?? []
    }
    
    // alternative one file per framework
//    func fetchClassesAndFunctions(for frameworkName: String) -> [FrameworkClass] {
//        let fileName = frameworkName.lowercased() + "_methods" // e.g., "realitykit_methods"
//        guard
//            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
//            let data = try? Data(contentsOf: url),
//            let classes = try? JSONDecoder().decode([FrameworkClass].self, from: data)
//        else { return [] }
//        return classes
//    }
}


