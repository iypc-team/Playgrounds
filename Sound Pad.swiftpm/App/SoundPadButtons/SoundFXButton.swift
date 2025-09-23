import Foundation
import SwiftUI
import AVFAudio

struct SoundFXButton: View {
    var sound: SoundFXSounds
    var color: Color
    var pitch: Double = 0.0
    var speed: Double = 1.0
    var filter: AVAudioUnitDistortionPreset? = nil
    var volume: Float = 1.0

    @State private var isPressed: Bool = false
    @State private var isAnimating: Bool = false
    
    @EnvironmentObject private var mic: Recorder
    @StateObject private var soundPlayer = SoundPlayer(engine: Recorder.engine)
    
    init(sound: SoundFXSounds, color: Color) {
        self.sound = sound
        self.color = color
    }
    
    var body: some View {
        SoundFXButtonView(color: color, sound: sound.rawValue, animateGradient: $isAnimating)
            .opacity(isPressed ? 0.6: 1)
            .onTapGesture {
                animateButton()
                soundPlayer.playSound(sound, pitch: pitch, speed: speed, volume: volume, filter: filter)
            }
            .accessibilityLabel(soundName)
            .accessibilityHint("Click or double tap to hear \(soundName)")
    }

    var soundName: String {
        return "\(sound.rawValue)"
    }
    
    func opacity() {
        isPressed.toggle()
        _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            withAnimation(.linear) {
                isPressed.toggle()
            }
        }
    }
    
    func animateButton() {
        let node = AVAudioNode()
        let length = AudioPlayer.soundLength(sound.rawValue, speed: speed)
        
        opacity()
        mic.loopingButtons[node] = $isAnimating
        withAnimation(.linear(duration: length)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + length) {
            isAnimating = false
            mic.loopingButtons[node] = nil
        }
    }
}

extension SoundFXButton {
    func speed(_ speed: Double) -> Self {
        var copy = self
        copy.speed = speed
        return copy
    }
    
    func pitch(_ pitch: Pitch) -> Self {
        var copy = self
        copy.pitch = pitch.rawValue
        return copy
    }
    
    func filter(_ filter: AVAudioUnitDistortionPreset?) -> Self {
        var copy = self
        copy.filter = filter
        return copy
    }
    
    func volume(_ volume: Float) -> Self {
        var copy = self
        copy.volume = volume
        return copy
    }
}
