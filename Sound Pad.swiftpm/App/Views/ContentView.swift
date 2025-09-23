import SwiftUI

struct ContentView: View {
    @StateObject private var mic = Recorder()
    let columns = [GridItem(.adaptive(minimum: 100, maximum: .infinity))]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                SoundPadView()
            }
            .padding(.horizontal)
            .padding(.top)
            .overlay(alignment: .topTrailing){
                StopAllSoundsButton()
            }
            
            RecordingView()
                .frame(height: mic.isRecording == .on ? 200 : 100, alignment: .bottom)
                .background(Color.sectionColor)
                .padding(.top, 5)
        }
        .padding(.top)
        .environmentObject(mic)
        .background(Color.backgroundColor)

    }
}
