import SwiftUI
extension String {
    var name: String {
        return self.description.camelCaseToWords()
    }

    func camelCaseToWords() -> String {
        return unicodeScalars.dropFirst().reduce(String(prefix(1))) {
            guard let prev = $0.last else {
                return $0 + String($1)
            }
            if prev.isLowercase && CharacterSet.uppercaseLetters.contains($1) {
                return $0 + " " + String($1)
            } else {
                return $0 + String($1)
            }
        }
    }
    
}

