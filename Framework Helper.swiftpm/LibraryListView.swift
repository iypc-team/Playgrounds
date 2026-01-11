// 
// 
//  print

import Foundation

class LibraryListView: ObservableObject {
    @Published var frameworks: [Framework] = []
    
    func fetchFrameworks() {
        // Sort the frameworks alphabetically
        self.frameworks = FrameworksConstants.knownFrameworks
            .map { Framework(name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

