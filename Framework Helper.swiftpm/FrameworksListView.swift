// 
// 

import Foundation

class FrameworksViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    
    func fetchFrameworks() {
        // Fetching all frameworks
        let bundles = Bundle.allFrameworks
        self.frameworks = bundles.compactMap { bundle in
            // Extracting the framework name
            guard let name = bundle.bundlePath.components(separatedBy: "/").last else {
                return nil
            }
            return Framework(name: name)
        }
    }
}

