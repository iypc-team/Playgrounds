// SpaceshipApp 06/11/2026-2
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipApp.swiftpm

// ContentView.swift

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
            .padding(.vertical, 10)
            .font(.system(size: Dimensions.fontSize, weight: .semibold))
            .foregroundColor(borderColor)
            .background(Color.black.opacity(0.3))
            .cornerRadius(Dimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    
    var body: some View {
        ZStack {
            // 3D View when loaded
            if let _ = model.entity {
                RealityKitView(model: model)
                    .gesture(magnificationGesture)
                    .gesture(dragGesture)
            } 
            // Loading / Error
            else if let error = model.loadError {
                errorView(error)
            } else {
                loadingView
            }
            
            // Controls always on top when model is ready
            if model.entity != nil {
                controlsOverlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onDisappear {
            model.resetAll()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading 3D Fighter...")
                .foregroundColor(.white)
        }
        .onAppear {
            model.loadModel()
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Load Failed")
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Retry") {
                model.loadModel()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { model.updateScale(with: Float($0)) }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { model.updateRotation(from: $0.translation) }
    }
    
    private var controlsOverlay: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                Button("Start Demo Rotation") {
                    Task { model.rotateModel() }
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .green))
                
                Button("Stop & Reset") {
                    model.resetAll()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .red))
            }
            
            HStack(spacing: 20) {
                Button("Start Motion") {
                    model.startMotion()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .blue))
                .disabled(model.isMotionActive)
                
                Button("Cancel Motion") {
                    model.cancelMotion()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .orange))
                .disabled(!model.isMotionActive)
            }
        }
        .padding(.bottom, 50)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
