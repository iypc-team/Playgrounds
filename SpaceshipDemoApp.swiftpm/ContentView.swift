// SpaceshipDemoApp 01/06/2026-3
/*
 
 https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipDemoApp.swiftpm
 
 */
// logger

import SwiftUI
import OSLog

private let conversionFactor = (Float.pi / 180)
public let logger = Logger(subsystem: "com.iypc.SpaceshipDemoApp", category: "SpaceshipDemoApp")

// Example usage:
//logger.debug("Scale: \(value)")
//logger.error("Failed to load model.")

struct printInfo {
    init() { print("ContentView()") }
}

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
                                logger.debug("Magnification gesture: scale updated to \(Float($0))")
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { 
                                    let _ = model.updateRotation(from: $0.translation)
                                    logger.debug("Drag gesture: translation \(String(describing: $0.translation))")
                                }
                            )
                    )
                    .overlay(overlayButtons, alignment: .bottom)
            } else {
                ProgressView("Loading model…")
                    .onAppear { 
                        logger.info("Starting model load")
                        model.loadModel()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var overlayButtons: some View {
        HStack {
            Button("Start Rotation") {
                logger.info("Start Rotation button pressed")
                Task { model.rotateModel() }
            }.buttonStyle(HighlightedButtonStyle(borderColor: .green, backgroundColor: .clear))
            
            Button("Cancel Rotation") {
                logger.info("Cancel Rotation button pressed")
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
