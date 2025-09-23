import SwiftUI

struct StopAllSoundsButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var mic: Recorder
    @StateObject private var soundPlayer = SoundPlayer(engine: Recorder.engine)
    @State private var isHidden = true
    
    var body : some View {
        Button {
            soundPlayer.stopAllSounds(loopingButtons: $mic.loopingButtons)
        } label: {
            ZStack {
                Capsule()
                    .foregroundStyle(.ultraThinMaterial)
                Capsule()
                    .foregroundStyle(colorScheme == .light ? Material.ultraThinMaterial.blendMode(.normal) : Material.ultraThinMaterial.blendMode(.plusLighter))
                Text("Reset")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 75, height: 40)
            .padding(.horizontal, 10)
        }
        .onChange(of: mic.loopingButtons.isEmpty) { _ in
            withAnimation {
                isHidden.toggle()
            }
        }
        .opacity(isHidden ? 0 : 1)
        .accessibilityLabel("Reset button")
        .accessibilityHint("Click or double tap to stop all sounds")
    }
}
