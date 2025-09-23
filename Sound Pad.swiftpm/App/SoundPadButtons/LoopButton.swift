import SwiftUI
import AVFoundation

struct LoopButton: View {
    var sound: Sound
    var color: Color
    
    var pitch: Double = 0.0
    var speed: Double = 1.0
    var filter: AVAudioUnitDistortionPreset? = nil
    var volume: Float = 1.0
    
    let node = AVAudioPlayerNode()
    @State var isLooping = false

    @EnvironmentObject private var mic: Recorder
    @StateObject private var soundPlayer = SoundPlayer(engine: Recorder.engine)
    
    var soundLength: Double {
        return AudioPlayer.soundLength(sound, speed: speed)
    }
    
    init(beat: BeatSounds, color: Color) {
        self.sound = beat.rawValue
        self.color = color
    }
    
    init(bass: BassSounds, color: Color) {
        self.sound = bass.rawValue
        self.color = color
    }
    
    init(melodic: MelodicSounds, color: Color) {
        self.sound = melodic.rawValue
        self.color = color
    }
    
    init(ambient: AmbientSounds, color: Color) {
        self.sound = ambient.rawValue
        self.color = color
    }

    var body: some View {
        LoopButtonView(color: color, sound: sound, soundLength: soundLength, isLooping: isLooping, delay: $soundPlayer.beatDelay)
            .onTapGesture {
                isLooping.toggle()
                if isLooping {
                    soundPlayer.playLoop(sound, node: node, pitch: pitch, speed: speed, volume: volume, filter: filter, isRecording: $mic.isRecording, isLooping: $isLooping, loopingButtons: $mic.loopingButtons)
                }
            }
            .accessibilityLabel(sound)
            .accessibilityHint("Click or double tap to hear \(sound)")
            .accessibilityElement(children: .combine)
    }
}


extension LoopButton {
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
