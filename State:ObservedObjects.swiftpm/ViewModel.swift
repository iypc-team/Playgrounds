import SwiftUI

class CounterViewModel: ObservableObject  {
    @Published var count = 0
    
    func incrementCount()  {
        count += 1
    }
    func decrementCount()  {
        count -= 1
    }
}
