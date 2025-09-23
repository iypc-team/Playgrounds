import SwiftUI

struct ButtonView: View {
    @State private var isPressed = false
    var color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(RadialGradient(
                gradient: Gradient(colors: [color.opacity(0.6), color]),
                center: .center,
                startRadius: 0,
                endRadius: 80))
    }
}
