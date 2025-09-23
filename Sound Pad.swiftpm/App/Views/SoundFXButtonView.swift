import SwiftUI

struct SoundFXButtonView: View {
    var color: Color
    var sound: Sound
    @Binding var animateGradient: Bool

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(RadialGradient(gradient: Gradient(colors: [color.opacity(0.7), color]), center: .center, startRadius: 0, endRadius: 80))
                HStack {
                    if animateGradient {
                        Spacer()
                    }
                    LinearGradient(colors: [.clear, .white.opacity(animateGradient ? 0.7 : 0)], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 15)
                    if !animateGradient {
                        Spacer()
                    }
                }
                .clipShape( RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .aspectRatio(1.0, contentMode: .fit)
            
            Text("\(sound.description.name)")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}


