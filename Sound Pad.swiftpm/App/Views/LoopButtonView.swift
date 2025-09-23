import SwiftUI

struct LoopButtonView: View {
    var color: Color
    var sound: Sound
    let soundLength: Double
    var isLooping: Bool
    @Binding var delay: Double
    @State private var animateGradient = false
    @State private var startTime: TimeInterval = 0
    @State private var percentagePlayed: Double = 0
    @State private var timer: Timer?
    @State var isPulsing: Bool = false

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.white)
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [color.opacity(0.5), color]), center: .center, startRadius: 0, endRadius: 40))
                Circle()
                    .fill(AngularGradient(gradient: Gradient(colors: [.white.opacity(animateGradient ? 0.5 : 0), .clear]), center: .center, startAngle: .degrees(0), endAngle: .degrees(180)))
                    .rotationEffect(.degrees(360*percentagePlayed))
            }
            .aspectRatio(1.0, contentMode: .fit)
            .opacity(isPulsing ? 0.6 : 1)
            .onChange(of: isLooping) { _ in
                if !isLooping {
                    let initialTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        opacity()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        initialTimer.invalidate()
                        withAnimation(.linear) {
                            animateGradient = true
                        }
                        startTime = Date.timeIntervalSinceReferenceDate
                        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                            percentagePlayed = (Date.timeIntervalSinceReferenceDate - startTime) / soundLength
                            if percentagePlayed > 1 {
                                startTime = Date.timeIntervalSinceReferenceDate
                            }
                        }
                    }
                } else {
                    animateGradient = false
                    if let timer = timer {
                        timer.invalidate()
                    }
                    percentagePlayed = 0
                }
            }
            
            Text("\(sound.description.name)")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
    
    func opacity() {
        isPulsing.toggle()
        _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            withAnimation(.linear) {
                isPulsing.toggle()
            }
        }
    }
}
