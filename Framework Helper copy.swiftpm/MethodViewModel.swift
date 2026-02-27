//   MethodViewModel.swift
//  

// MethodViewModel.swift

// MethodViewModel.swift

import SwiftUI

final class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    let framework: Framework
    
    init(framework: Framework) {
        self.framework = framework
        Task { await fetchMethods() }
    }
    
    @MainActor
    func fetchMethods() async {
        let currentLibrary = framework.name
        
        guard
            let url = Bundle.main.url(forResource: "methods", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]]
        else {
            methods = ["No methods available for this framework"]
            return
        }
        
        methods = json[currentLibrary, default: ["No methods available for this framework"]]
    }
}

//import SwiftUI
//
//class MethodViewModel: ObservableObject {
//    @Published var methods: [String] = []
//    let framework: Framework
//    
//    init(framework: Framework) {
//        self.framework = framework
//        Task { await fetchMethods() }
//    }
//    //  in MethodViewModel the function 'fetchMethods()' is supposed to create a list of all methods within 'framework'
//    @MainActor
//    func fetchMethods() async {
//        print("func fetchMethods()")
//        let currentLibrary = framework.name
//        print("currentLibrary: \(currentLibrary)")
//        
//        if let url = Bundle.main.url(forResource: "methods", withExtension: "json"),
//           let data = try? Data(contentsOf: url),
//           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
//            methods = json[currentLibrary] ?? ["No methods available for this framework"]
//        } else {
//            methods = ["init()", "deinit()", "someMethod(param:)"]
//        }
//        print("Fetching methods for \(currentLibrary)")
//        print("methodsArray: \(methods)")
//    }
//}
