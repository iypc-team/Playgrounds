// 
// 

import Foundation

class LibraryListView: ObservableObject {
    @Published var frameworks: [Framework] = []
    
    init() {
        print("class LibraryListView: ObservableObject")
    }
    
    func fetchFrameworks() {
        print("func fetchFrameworks()")
        self.frameworks = FrameworksConstants.sortedFrameworks()
    }
}


