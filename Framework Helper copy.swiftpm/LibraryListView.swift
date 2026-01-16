// 
// is LibraryListView or LibraryViewModel ever accessed

import Foundation

class LibraryListView: ObservableObject {
    @Published var frameworks: [Framework] = []
    
    func fetchFrameworks() {
        self.frameworks = FrameworksConstants.sortedFrameworks()
    }
}

