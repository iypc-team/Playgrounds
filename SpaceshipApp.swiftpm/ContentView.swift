// SpaceshipApp 06/10/2026-2
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipApp.swiftpm

import SwiftUI

private enum Dimensions {
    static let buttonPadding: CGFloat = 12
    static let fontSize: CGFloat = 17
    static let cornerRadius: CGFloat = 10
}

struct HighlightedButtonStyle: ButtonStyle {
    let borderColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Dimensions.buttonPadding)
            .padding(.vertical, 8)
            .font(.system(size: Dimensions.fontSize, weight: .semibold))
            .foregroundColor(borderColor)
            .background(Color.black.opacity(0.25))
            .cornerRadius(Dimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadius)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        ZStack {
            if let _ = model.entity {
                RealityKitView(model: model)
                    .gesture(magnificationGesture)
                    .gesture(dragGesture)
                    .overlay(controlsOverlay, alignment: .bottom)
            } else if let error = model.loadError {
                errorView(error)
            } else {
                loadingView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                model.updateScale(with: Float(value))
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                model.updateRotation(from: value.translation)
            }
    }
    
    private var controlsOverlay: some View {
        HStack(spacing: 16) {
            Button("Start Demo Rotation") {
                Task { model.rotateModel() }
            }
            .buttonStyle(HighlightedButtonStyle(borderColor: .green))
            
            Button("Stop & Reset") {
                model.cancelRotation()
                model.resetRotation()
            }
            .buttonStyle(HighlightedButtonStyle(borderColor: .red))
        }
        .padding(.bottom, 40)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Loading 3D model…")
                .foregroundColor(.secondary)
        }
        .onAppear {
            model.loadModel()
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Failed to load model")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
