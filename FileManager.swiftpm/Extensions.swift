import SwiftUI

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension Double {
    func convertDoubleToInt(_ input: Double) -> Int {
        return Int(input)
    }
//    let doubleValue: Double = 15.3
//    let intValue = convertDoubleToInt(doubleValue)
//    print(intValue)  // Output: 15
}





