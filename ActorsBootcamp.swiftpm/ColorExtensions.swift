// ColorExtensions
import SwiftUI

extension Color {
    public static var cardinalRed: Color { 
        return Color(UIColor(red: 196/255, green: 30/255, blue: 58/255, alpha: 1.0))
    }
}

 //  forestGreen: RGB color code is rgb(1,68,33)
extension Color {
    public static var forestGreen: Color { 
        return Color(UIColor(red: 1/255, green: 68/255, blue: 33/255, alpha: 1.0))
    }
}

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}

let backgroundGradient = LinearGradient(
    colors: [Color.yellow, Color.forestGreen],
    startPoint: .top, endPoint: .bottom)
