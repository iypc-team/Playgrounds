// 
//  

import SwiftUI

class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    let framework: Framework
    
    init(framework: Framework) {
        self.framework = framework
        
    }
    
    func fetchMethods() async {
        // Your existing code here, but if it involves I/O, consider using async alternatives like URLSession
        let currentLibrary = framework.name
        print("currentLibrary: \(currentLibrary)")
        
        if let url = Bundle.main.url(forResource: "methods", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
            methods = json[currentLibrary] ?? ["No methods available for this framework"]
        } else {
            methods = [
                "init()",
                "deinit()",
                "someMethod(param:)"
            ]
        }
        
        print("Fetching methods for \(currentLibrary)")
    }
}
