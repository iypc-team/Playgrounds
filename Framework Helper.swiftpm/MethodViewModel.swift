// 
// 
//  print

import SwiftUI

class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    let framework: Framework
    
    init(framework: Framework) {
        self.framework = framework
        fetchMethods()
    }
    
    func fetchMethods() {
        let currentLibrary = framework.name
        print("currentLibrary: \(currentLibrary)")
        
        // Attempt to load methods from a bundled JSON file (e.g., methods.json in the app bundle)
        // JSON structure: {"SwiftUI": ["Text(_: String)", "Image(_: String)", ...], "UIKit": [...], ...}
        if let url = Bundle.main.url(forResource: "methods", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
            // Retrieve only methods for the current library
            methods = json[currentLibrary] ?? ["No methods available for this framework"]
        } else {
            // Fallback to hardcoded placeholders if JSON loading fails
            methods = [
                "init()",
                "deinit()",
                "someMethod(param:)"
            ]
        }
        
        // Optional: Log the library for debugging
        print("Fetching methods for \(currentLibrary)")
    }
    
//    func fetchMethods() {
//        let currentLibrary = framework.name
//        // Example: Placeholder for fetching methods for the framework
//        // Replace with actual logic, e.g., reflection or API calls
//        print(currentLibrary)
//        methods = [
//            "init()",
//            "deinit()",
//            "someMethod(param:)",
//            // Add more as needed
//        ]
//    }
}

