// SpaceshipDemoApp 01/07/2026-1
/*
 
 https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipDemoApp.swiftpm
 
 */

import SwiftUI

private let conversionFactor = (Float.pi / 180)

struct HighlightedButtonStyle: ButtonStyle {
    let borderColor: Color
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(borderColor)
            .background(backgroundColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        Group {
            if let _ = model.entity {
                RealityKitView(model: model)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { 
                                model.updateScale(with: Float($0))
                            }
                            .onEnded {
                                print("Magnification gesture: final scale \(Float($0))")
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { 
                                    let _ = model.updateRotation(from: $0.translation)
                                }
                                .onEnded {
                                    print("Drag gesture: final translation \(String(describing: $0.translation))")
                                }
                            )
                    )
                    .overlay(overlayButtons, alignment: .bottom)
            } else {
                ProgressView("Loading model…")
                    .onAppear { 
                        print("Starting model load")
                        model.loadModel()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var overlayButtons: some View {
        HStack {
            Button("Start Rotation") {
                print("Start Rotation button pressed")
                Task { model.rotateModel() }
            }.buttonStyle(HighlightedButtonStyle(borderColor: .green, backgroundColor: .clear))
            
            Button("Cancel Rotation") {
                print("Cancel Rotation button pressed")
                model.cancelRotation()
                model.resetRotation()
            }.buttonStyle(HighlightedButtonStyle(borderColor: .red, backgroundColor: .clear))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
