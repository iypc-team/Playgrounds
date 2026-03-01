// Extensions.swift
// Consolidated and simplified Double helpers

import Foundation

extension Double {
    /// Rounds the double to `places` decimal places.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Convert self to Int by truncation.
    var toInt: Int { Int(self) }
}
