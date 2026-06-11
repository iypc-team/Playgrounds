// SpaceshipApp 06/11/2026-3
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipApp.swiftpm

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
            .overlay(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadius)
                    .stroke(borderColor, lineWidth: 1.5)
            )
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
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { model.updateRotation(from: $0.translation) }
                    )
                    .overlay(overlayButtons, alignment: .bottom)
            } else if let error = model.loadError {
                errorView(error)
            } else {
                ProgressView("Loading model…")
                    .onAppear {
                        model.loadModel()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onDisappear {
            model.resetAll()
        }
    }
    
    private var overlayButtons: some View {
        VStack(spacing: 16) {
            // Rotation buttons
            HStack(spacing: 20) {
                Button("Start Rotation") {
                    Task { model.rotateModel() }
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .green, backgroundColor: .clear))
                
                Button("Cancel Rotation") {
                    model.resetAll()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .red, backgroundColor: .clear))
            }
            
            // New Motion buttons
            HStack(spacing: 20) {
                Button("Start Motion") {
                    model.startMotion()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .blue, backgroundColor: .clear))
                .disabled(model.isMotionActive)
                
                Button("Cancel Motion") {
                    model.cancelMotion()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .orange, backgroundColor: .clear))
                .disabled(!model.isMotionActive)
            }
        }
        .padding(.bottom, 40)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Load Failed")
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Retry") {
                model.loadModel()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
