// AI SpaceshipDemoApp 12/15/2025-1
/*
 https://github.com/iypc-team/Playgrounds/tree/main/AI%20SpaceshipDemoApp.swiftpm
 */
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI
import OSLog

private let conversionFactor = (Float.pi / 180)
private let logger = Logger(subsystem: "com.iypc.AISpaceshipDemoApp", category: "ContentView")

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
            .font(.system(size: 18, weight: .heavy))
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
                            .onChanged { model.updateScale(with: Float($0)) }
                            .simultaneously(with: DragGesture()
                                .onChanged { let _ = model.updateRotation(from: $0.translation) }
                            )
                    )
                    .overlay(overlayButtons, alignment: .bottom)
            } else {
                ProgressView("Loading model…")
                    .onAppear { model.loadModel() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var overlayButtons: some View {
        HStack(spacing: 20) {
            Button("Start Rotation") {
                Task { model.rotateModel() }
            }.buttonStyle(HighlightedButtonStyle(borderColor: .green, backgroundColor: .black))
            
            Button("Cancel Rotation") {
                model.cancelRotation()
                model.resetRotation()
            }.buttonStyle(HighlightedButtonStyle(borderColor: .red, backgroundColor: .black))
        }
    }
}
