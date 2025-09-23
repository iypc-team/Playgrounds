import SwiftUI

struct Visualizer: View {
    var value: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.red)
                .frame(width: 1, height: value)
                .accessibilityLabel("Bar height \(value)")
        }
    }
}
