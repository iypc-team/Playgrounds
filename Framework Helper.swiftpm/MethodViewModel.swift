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
        // Example: Placeholder for fetching methods for the framework
        // Replace with actual logic, e.g., reflection or API calls
        print(currentLibrary)
        methods = [
            "init()",
            "deinit()",
            "someMethod(param:)",
            // Add more as needed
        ]
    }
}

