import SwiftUI
import Observation

struct User {
    var firstName = "Ralph"
    var lastName = "Krueger"
    var edits: UInt = 0
    
    mutating func buttonPressed() {
        self.edits += 1
        print("Edits: \(edits)")
    }
}
