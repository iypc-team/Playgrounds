import SwiftUI

struct SoundPadView: View {
    var body: some View {
        Divider()
        /*#-code-walkthrough(1.exploreLoop)*/Beats {
            LoopButton(beat: .CosmicBeat, color: /*#-code-walkthrough(1.changeColor)*/ .teal /*#-code-walkthrough(1.changeColor)*/)
                .volume(100.0)
                .pitch(.D_b)
            LoopButton(bass: .LesInfernoBass, color: .teal)
                .volume(100.0)
                .pitch(.D_b)
            LoopButton(melodic: .SensationArpeggio, color: .cyan)
                .volume(50.0)
                .pitch(.E)
//            LoopButton(beat: .HotBeat1, color: .cyan)
//            LoopButton(beat: .DiscoBeat6, color: .blue)
//            LoopButton(beat: .DiscoBeat1, color: .white)
                
            //#-learning-code-snippet(1.addNewBeat)
        }/*#-code-walkthrough(1.exploreLoop)*/
        //#-learning-code-snippet(3.learnBass)
        //#-learning-code-snippet(3.learnMelodyAmbient)
        //#-learning-code-snippet(4.learnSoundFX)
    }
}

