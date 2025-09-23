import SwiftUI
import AudioToolbox
import CoreMedia

struct RecordingView: View {
    @EnvironmentObject var mic: Recorder
    @State private var showShareSheet = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                HStack(alignment: .center, spacing: 4) {
                    if mic.isRecording == .on && !UIAccessibility.isVoiceOverRunning {
                        ForEach(mic.newSamples, id: \.id) { sample in
                            let adjustedValue = mic.adjustSampleHeight(value: sample.value)
                            Visualizer(value: adjustedValue)
                        }
                    }
                }
                .frame(maxWidth: geo.size.width, maxHeight: mic.isRecording == .on ? 100 : 0)
                .opacity(mic.isRecording == .on ? 1 : 0)
                   
                StopWatchView(time: mic.progressTimeRecording)
                    .frame(height: mic.isRecording == .on ? 20 : 0)
                    .opacity(mic.isRecording == .on ? 1 : 0)
                    .foregroundColor(Color.recordingColor)
                
                ZStack {
                    Circle()
                        .stroke(mic.isRecording == .on ? Color.recordingColor : Color.white, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    recordButton()
                        .frame(width: 40, height: 40)
                        .scaleEffect(mic.isRecording == .on ? 0.5 : 1)
                        .foregroundColor(Color.recordingColor)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if mic.isRecording == .on {
                                    mic.isRecording = .off
                                } else {
                                    mic.isRecording = .on
                                }
                                showShareSheet = mic.startRecording(countSamples: Int(geo.size.width*0.2))
                            }
                        }
                        .accessibilityLabel("Record button")
                        .sheet(isPresented: $showShareSheet) {
                            PlaybackSheetView(showShareSheet: $showShareSheet)
                                .environmentObject(mic)
                                .presentationDetents([.fraction(0.4)])
                                .interactiveDismissDisabled()
                        }
                }
                .accessibilityElement(children: .contain)
                .frame(maxHeight: .infinity)
            }
            .accessibilityAction(.magicTap) {
                if mic.isRecording == .on {
                    mic.isRecording = .off
                } else {
                    mic.isRecording = .on
                }
                showShareSheet = mic.startRecording(countSamples: Int(geo.size.width*0.45))
            }
        }
    }
    
    @ViewBuilder
    private func recordButton()-> some View {
        if mic.isRecording == .on {
            RoundedRectangle(cornerRadius: 10)
        } else {
            Circle()
        }
    }
}
