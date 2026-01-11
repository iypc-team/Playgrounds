// 
// 

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
        self.frameworks = FrameworksConstants.sortedFrameworks()
    }
}

