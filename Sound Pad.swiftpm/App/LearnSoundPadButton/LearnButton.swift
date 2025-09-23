import SwiftUI

struct LearnButton: View {
    @StateObject var soundPlayer = SoundPlayer()
    var body: some View {
        VStack {
            Button ("Tap Me") {
                /*#-code-walkthrough(6.soundPadButton)*/
                soundPlayer.playSound(.FirstGearFX)
                /*#-code-walkthrough(6.soundPadButton)*/
            }
            //#-learning-code-snippet(6.addButton)
        }
    }
}

struct LearnButton_Previews: PreviewProvider {
    static var previews: some View {
        LearnButton()
            .frame(maxWidth: 200, maxHeight: 200)
    }
}

