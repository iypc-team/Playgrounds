//  Defcon4Images_PNG  01/04/2026-2
/*
https://github.com/iypc-team/Playgrounds/tree/main/Defcon4Images_PNG.swiftpm
 */

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel(sceneName: "newFighter.scn")
    @State private var pngFileURLs: [URL] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {  // Updated from NavigationView
            VStack {
                SceneView(
                    scene: viewModel.sceneModel.scene,
                    rotationX: $viewModel.currentRotationX,
                    rotationY: $viewModel.currentRotationY,
                    rotationZ: $viewModel.currentRotationZ,
                    isRotatingX: $viewModel.isRotatingX,
                    isRotatingY: $viewModel.isRotatingY,
                    isRotatingZ: $viewModel.isRotatingZ,
                    viewModel: viewModel
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Text("SceneKit View")
                        .foregroundColor(.white)
                        .background(Color.red.opacity(0.3))
                        .padding(4)
                        .cornerRadius(5),
                    alignment: .top
                )
            }
            .overlay(
                VStack {
                    HStack {
                        RotateButton(action: { viewModel.rotateModelOnXAxis() }, label: "Rotate X", color: .green)
                        RotateButton(action: { viewModel.rotateModelOnYAxis() }, label: "Rotate Y", color: .purple)
                        RotateButton(action: { viewModel.rotateModelOnZAxis() }, label: "Rotate Z", color: .orange)
                    }
                    
                    HStack {
                        Button(action: { deleteAllPNGFiles() }) {
                            Text("Delete All PNGs")
                                .padding()
                                .background(Color.red.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        .accessibilityLabel("Delete all PNG files")
                        
                        Button(action: { loadPNGFiles() }) {
                            Text("Load PNGs")
                                .padding()
                                .background(Color.blue.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        .accessibilityLabel("Load PNG files")
                        
                        NavigationLink(destination: ImageGridView(pngFileURLs: pngFileURLs)) {
                            Text("View Image Grid")
                                .padding()
                                .background(Color.teal.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        .accessibilityLabel("Navigate to image grid view")
                    }
                }
                    .padding(.bottom, 5),
                alignment: .bottom
            )
        }
        .onAppear { loadPNGFiles() }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func deleteAllPNGFiles() {
        Task {
            do {
                try await viewModel.deleteAllPNGFilesAsync()
                await MainActor.run { loadPNGFiles() }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete PNGs: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func loadPNGFiles() {
        Task {
            do {
                pngFileURLs = try await viewModel.loadPNGFilesAsync()
            } catch {
                errorMessage = "Failed to load PNGs: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

struct RotateButton: View {
    let action: () -> Void
    let label: String
    let color: Color
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .padding()
                .background(color.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(5)
        }
        .accessibilityLabel("Rotate model on \(label.lowercased()) axis")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
