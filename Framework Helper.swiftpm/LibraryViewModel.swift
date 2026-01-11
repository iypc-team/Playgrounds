// 
// 
//  print

import SwiftUI

class LibraryViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    @Published var searchText: String = ""
    
    var filteredFrameworks: [Framework] {
        if searchText.isEmpty {
            return frameworks
        } else {
            return frameworks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init() {
        fetchFrameworks()
    }
    
    func fetchFrameworks() {
        // Sort the frameworks alphabetically
        self.frameworks = FrameworksConstants.knownFrameworks
            .map { Framework(name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
