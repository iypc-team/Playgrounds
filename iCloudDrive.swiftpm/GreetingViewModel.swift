//  GreetingViewModel.swift

import Foundation

class GreetingViewModel: ObservableObject {
    // Published property that the View will observe for updates
    @Published var greeting: String = ""
    
    private let model = GreetingModel()
    
    // Function to fetch the greeting from the model
    func loadGreeting() {
        self.greeting = model.fetchGreeting()
    }
}

