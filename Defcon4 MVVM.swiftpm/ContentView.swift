//  Defcon4 MVVM  12/30/2025-1
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4%20MVVM.swiftpm
 */

import SwiftUI
import SceneKit

struct ContentView: View {
    // Observes changes in the ViewModel
    @StateObject var viewModel = SceneViewModel(sceneName: "newFighter.scn")
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    mainContent()
                    // .navigationTitle("Content View")  // Removed: Comment out to hide the title
                }
            } else {
                NavigationView {
                    mainContent()
                    // .navigationTitle("Content View")  // Removed: Comment out to hide the title
                }
            }
        }
        .onAppear {
            viewModel.loadPNGFiles()  // Load PNGs when the view appears
            // print("loadPNGFiles()")
        }
    }
    
    private func mainContent() -> some View {
        VStack {
            SceneView(
                scene: viewModel.sceneModel.scene,
                rotationX: $viewModel.currentRotationX,
                rotationY: $viewModel.currentRotationY,
                rotationZ: $viewModel.currentRotationZ,
                isRotatingX: $viewModel.isRotatingX,
                isRotatingY: $viewModel.isRotatingY,
                isRotatingZ: $viewModel.isRotatingZ, viewModel: SceneViewModel
                // Cannot convert value of type 'SceneViewModel' to expected argument type 'SceneViewModel'
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Text("SceneKit View")
                    .foregroundColor(.white)
                    .background(Color.red.opacity(0.1))
                    .padding(4)
                    .cornerRadius(5),
                alignment: .top
            )
        }
        .overlay(
            VStack {
                HStack {
                    Button(action: {
                        viewModel.rotateModelOnXAxis()
                        print("Started rotating model on X axis incrementally to 360°")
                    }) {
                        Text("Rotate X")
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        viewModel.rotateModelOnYAxis()
                        print("Started rotating model on Y axis incrementally to 360°")
                    }) {
                        Text("Rotate Y")
                            .padding()
                            .background(Color.purple.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        viewModel.rotateModelOnZAxis()
                        print("Started rotating model on Z axis incrementally to 360°")
                    }) {
                        Text("Rotate Z")
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                
                HStack {
                    Button(action: {
                        viewModel.deleteAllPNGFiles()
                        // Note: loadPNGFiles() is now called internally in deleteAllPNGFiles()
                    }) {
                        Text("Delete All PNGs")
                            .padding()
                            .background(Color.red.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        viewModel.loadPNGFiles()
                    }) {
                        Text("Load PNGs")
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    // NavigationLink to transition to ImageGridPresentationView
                    NavigationLink(destination: ImageGridView(pngFileURLs: viewModel.pngFileURLs)) {
                        Text("View Image Grid")
                            .padding()
                            .background(Color.teal.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
                .padding(.bottom, 5),
            alignment: .bottom
        )
    }
    
    // Removed: deleteAllPNGFiles() and loadPNGFiles() - now in ViewModel
    
    func listAllFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("All files in Documents directory:")
            for fileURL in files {
                print("- \(fileURL.lastPathComponent)")
            }
        } catch {
            print("Error listing files: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
