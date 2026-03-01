// Extensions.swift
// Consolidated Double and Color helpers

import Foundation
import SwiftUI
import UIKit

extension Double {
    /// Rounds the double to `places` decimal places.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Convert self to Int by truncation.
    var toInt: Int { Int(self) }
}

extension Color {
    public static var cardinalRed: Color {
        Color(UIColor(red: 196.0/255.0, green: 30.0/255.0, blue: 58.0/255.0, alpha: 1.0))
    }
    
    public static var navyBlue: Color {
        // rgb(1,1,128)
        Color(UIColor(red: 1.0/255.0, green: 1.0/255.0, blue: 128.0/255.0, alpha: 1.0))
    }
    
    public static var forestGreen: Color {
        // rgb(1,68,33)
        Color(UIColor(red: 1.0/255.0, green: 68.0/255.0, blue: 33.0/255.0, alpha: 1.0))
    }
}
