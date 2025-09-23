import SwiftUI


extension Color {
    public static var cardinalRed: Color { 
        return Color(UIColor(red: 196/255, green: 30/255, blue: 58/255, alpha: 1.0))
    }
}
extension Color{
    var forestGreen :Color {
        return Color(UIColor(red: 23/255, green: 74/255, blue: 67/255, alpha: 1.0))
    }
}

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}

extension UIImage {
    var thumbnail: UIImage? {
        get async {
            let size = CGSize(width: 200, height: 200)
            return await self.byPreparingThumbnail(ofSize: size)
        }
    }
}
