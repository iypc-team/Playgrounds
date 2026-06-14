// SpaceshipApp 06/14/2026-2
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SpaceshipApp.swiftpm. 

import SwiftUI

struct ContentView: View {
    @StateObject private var model = AirplaneModel()  // ← Fixed: Use AirplaneModel
    
    var body: some View {
        Group {
            if model.entity != nil {
                RealityKitView(model: model)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { model.updateScale(with: Float($0)) },
                            DragGesture()
                                .onChanged { model.updateRotation(from: $0.translation) }
                        )
                    )
                    .overlay(alignment: .top) { modelPicker }
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
    
    private var modelPicker: some View {
        Picker("Select Model", selection: $model.currentModelName) {
            ForEach(model.availableModels, id: \.self) { name in
                Text(name).tag(name)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: model.currentModelName) { newName in
            model.loadModel(named: newName)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(Constants.cornerRadius)
        .padding(.top, 8)
        .padding(.horizontal)
        .tint(.white)
    }
    
    private var overlayButtons: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                Button("Start Rotation") {
                    Task { model.rotateModel() }
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .green, backgroundColor: .clear))
                
                Button("Cancel Rotation") {
                    model.cancelRotation()
                }
                .buttonStyle(HighlightedButtonStyle(borderColor: .red, backgroundColor: .clear))
            }
            
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

// MARK: - Button Style
struct HighlightedButtonStyle: ButtonStyle {
    let borderColor: Color
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(Constants.buttonPadding)
            .font(.system(size: Constants.fontSize, weight: .medium))
            .foregroundColor(borderColor)
            .background(backgroundColor)
            .cornerRadius(Constants.cornerRadius)
            .scaleEffect(configuration.isPressed ? Constants.scaleFactor : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor, lineWidth: 1.5)
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
