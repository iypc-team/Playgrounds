import SwiftUI

struct PlaybackSheetView: View {
    @State var showAlert = false
    @Binding var showShareSheet: Bool
    @EnvironmentObject var mic: Recorder
    
    @State private var fullText: String = "Name your song"
    @State private var oldText: String = "Untitled"
    @AccessibilityFocusState private var textAccessibilityFocus: Bool
    var containsPlaceHolderText: Bool {
        fullText == "Name your song"
    }
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    var body: some View {
        VStack(alignment: .center) {
            RecordingTitleView(fullText: $fullText, oldText: $oldText, url: url)
                .accessibilityElement(children: .combine)
                .accessibilityFocused($textAccessibilityFocus)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 5)
                    .frame(height: 5)
                    .foregroundColor(Color.sectionTitleColor)
                    .opacity(0.6)
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: playbackDisplayCalc(geo.size.width), height: 5)
                    .foregroundColor(Color.primaryColor)
            }
            .frame(height:5)
            
            HStack {
                StopWatchView(time: mic.progressTimePlayback)
                Spacer()
                StopWatchView(time: mic.progressTimePlayback-mic.progressTimeRecording)
            }
            .foregroundColor(.primaryColor)
            .frame(height: 15)
            
            Button {
                mic.playbackToggle()
            } label: {
                Image(systemName: mic.isPlaying == .on ? "pause.fill" : "play.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.primaryColor)
            }
            .frame(width: 20, height: 20)
            .padding(.bottom)
            .accessibilityLabel(mic.isPlaying == .on ? "Pause" : "Play")
        }
        .onAppear {
            mic.intializePlayer()
            
            textAccessibilityFocus = true
        }
        .accessibilityAction(.magicTap) {
            mic.playbackToggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
        .background(
            Color.sectionColor
                .ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            ShareLink(item: MusicURL(text: (containsPlaceHolderText ? oldText : fullText) + Recorder.fileExtension).url) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryColor)
            }
            .presentationDetents([.fraction(0.5), .large])
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .alert("Are you done?", isPresented: $showAlert, actions: {
                Button("Delete", role: .destructive, action: {
                    mic.isRecording = .off
                    showShareSheet  = false
                    mic.player?.stop()
                    mic.isPlaying = .off
                })
            }, message: {
                Text("If you leave this screen your song will not be saved.")
            })
            .accessibilityLabel("Delete")
            .padding()
        }
    }
}

extension PlaybackSheetView {
    func playbackDisplayCalc(_ width: CGFloat) -> CGFloat {
        guard mic.progressTimeRecording != 0 else { return width }
        return CGFloat(Double(width) * (Double(mic.progressTimePlayback) / Double(mic.progressTimeRecording)))
    }
}

struct MusicURL {
    var text: String
    var url: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(text) else {
            fatalError("not a valid URL")
        }
        return url
    }
}

struct RecordingTitleView: View {
    @Binding var fullText: String
    @Binding var oldText: String
    var url: URL?
    var containsPlaceHolderText: Bool {
        fullText == "Name your song"
    }
    
    var body: some View {
        TextField("", text: $fullText)
            .padding()
            .font(.system(size: 17, weight: containsPlaceHolderText ? .regular : .semibold))
            .background(
                Color.backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            )
            .foregroundColor(containsPlaceHolderText ? Color.sectionTitleColor : Color.white)
            .onChange(of: fullText) { _ in
                if oldText != fullText {
                    let newURL = url?.appendingPathComponent(fullText + Recorder.fileExtension)
                    let oldURL = url?.appendingPathComponent(oldText + Recorder.fileExtension)
                    oldText = fullText
                    do {
                        if let oldURL = oldURL, let newURL = newURL {
                            try FileManager.default.moveItem(atPath: oldURL.path, toPath: newURL.path)
                        }
                    } catch {
                        print("Error renaming file! Threw: \(error.localizedDescription)")
                    }
                }
            }
            .onTapGesture {
                if containsPlaceHolderText {
                    fullText = ""
                }
            }
            .padding(.bottom, 30)
    }
}
