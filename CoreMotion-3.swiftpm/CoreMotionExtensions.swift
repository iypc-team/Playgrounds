import SwiftUI
import Foundation

extension Double {
    func rnd(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        let result = (self * divisor) / divisor
        return result
    }
}

extension Double {
    func roundToDecimalPlaces(_ fractionDigits: Int, _ printable: Bool) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        let result = Darwin.round(self * multiplier) / multiplier
        if printable {
            print(result)
        }
        print(result)
        return result
    }
}




//extension Double {
//    /// Rounds the double to decimal places value
//    func rounded(toPlaces places:Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return (self * divisor).rounded() / divisor
//    }
//}
