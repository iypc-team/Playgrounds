//  Defcon4 MVVM  01/01/2026-1
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Defcon4%20MVVM.swiftpm
 */
//  ContentView.swift
//  opacity(0.3)

import SwiftUI
import SceneKit

struct ContentView: View {
    // Observes changes in the ViewModel
    @StateObject var viewModel = SceneViewModel(sceneName: "newFighter.scn")
    @State private var pngFileURLs: [URL] = []  // To store the URLs of PNG files
    
    var body: some View {
        NavigationView {
            VStack {
                SceneView(
                    scene: viewModel.sceneModel.scene,
                    rotationX: $viewModel.currentRotationX,
                    rotationY: $viewModel.currentRotationY,
                    rotationZ: $viewModel.currentRotationZ,
                    isRotatingX: $viewModel.isRotatingX,
                    isRotatingY: $viewModel.isRotatingY,
                    isRotatingZ: $viewModel.isRotatingZ,
                    viewModel: viewModel  // Added this parameter to pass the viewModel to SceneView
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
                
                // Removed: Section to display PNG files inline (to avoid showing ScrollView here)
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
                            deleteAllPNGFiles()
                            loadPNGFiles()  // Refresh the list after deleting
                        }) {
                            Text("Delete All PNGs")
                                .padding()
                                .background(Color.red.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        
                        Button(action: {
                            loadPNGFiles()
                        }) {
                            Text("Load PNGs")
                                .padding()
                                .background(Color.blue.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        
                        // NavigationLink to transition to ImageGridPresentationView
                        NavigationLink(destination: ImageGridView(pngFileURLs: pngFileURLs)) {
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
            // Removed: .navigationTitle("Content View")  // This was displaying "Content View" in the navigation bar
        }
        .onAppear {
            loadPNGFiles()  // Load PNGs when the view appears
        }
    }
    
    func deleteAllPNGFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension == "png" }
            for fileURL in pngFiles {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted: \(fileURL.lastPathComponent)")
            }
            print("All PNG files deleted.")
        } catch {
            print("Error deleting files: \(error)")
        }
    }
    
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
    
    func loadPNGFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            pngFileURLs = files.filter { $0.pathExtension == "png" }
            print("Loaded \(pngFileURLs.count) PNG files.")
        } catch {
            print("Error loading PNG files: \(error)")
            pngFileURLs = []
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
