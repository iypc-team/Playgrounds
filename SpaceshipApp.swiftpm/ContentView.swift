// SpaceshipApp 01/07/2026-6
/*
 https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipApp.swiftpm
 */

import SwiftUI

// Define constants for design consistency
private enum Dimensions {
    static let buttonPadding: CGFloat = 10
    static let fontSize: CGFloat = 18
    static let cornerRadius: CGFloat = 8
    static let scaleFactor: CGFloat = 1.0
}

struct HighlightedButtonStyle: ButtonStyle {
    let borderColor: Color
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(Dimensions.buttonPadding)
            .font(.system(size: Dimensions.fontSize, weight: .medium))
            .foregroundColor(borderColor)
            .background(backgroundColor)
            .cornerRadius(Dimensions.cornerRadius)
            .scaleEffect(configuration.isPressed ? Dimensions.scaleFactor : 1.0)
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
                            .onChanged { model.updateScale(with: Float($0)) }
                            .onEnded {
                                print("Magnification gesture: final scale \(Float($0))")
                            }
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
            }
            .buttonStyle(HighlightedButtonStyle(borderColor: .green, backgroundColor: .clear))
            
            Button("Cancel Rotation") {
                print("Cancel Rotation button pressed")
                model.cancelRotation()
                model.resetRotation()
            }
            .buttonStyle(HighlightedButtonStyle(borderColor: .red, backgroundColor: .clear))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
