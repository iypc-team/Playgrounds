//  Inspect_SCN 03/17/2026-10
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm
//  

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    // Dynamically load .scn files from Resources directory
    @State private var resourceFiles: [String] = []
    
    // State for selected file, initialized after loading files
    @State private var selectedFile = "newFighter.scn"
    
    // State for showing inspection results
    @State private var inspectionResults: String = ""
    @State private var showInspection: Bool = false
    
    // State for showing bounding box
    @State private var showBoundingBox: Bool = false
    
    var body: some View {
        ZStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
                .onChange(of: selectedFile) { newValue in
                    viewModel.loadScene(for: newValue)
                    inspectionResults = "" // Reset inspection when scene changes
                    showBoundingBox = false  // Reset bounding box display on scene change
                }
                .onAppear {
                    loadResourceFiles()
                    // Load initial scene after resources are loaded
                    if resourceFiles.contains(selectedFile) {
                        viewModel.loadScene(for: selectedFile)
                    } else if let firstFile = resourceFiles.first {
                        selectedFile = firstFile
                        viewModel.loadScene(for: firstFile)
                    }
                }
            
            VStack {
                HStack {
                    Spacer()
                    Menu {
                        ForEach(resourceFiles, id: \.self) { file in
                            Button(file) {
                                selectedFile = file
                            }
                        }
                    } label: {
                        Text("Select File: \(selectedFile)")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    
                    Button(action: {
                        inspectGeometry()
                    }) {
                        Text("Inspect Geometry")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    .accessibilityLabel("Inspect the geometry of the current scene")
                    
                    Button(action: {
                        showBoundingBox.toggle()
                        if showBoundingBox {
                            if let boxNode = viewModel.sceneModel.createBoundingBoxNode() {
                                viewModel.scene.rootNode.addChildNode(boxNode)
                            }
                        } else {
                            viewModel.scene.rootNode.childNode(withName: "boundingBox", recursively: true)?.removeFromParentNode()
                        }
                    }) {
                        Text(showBoundingBox ? "Hide Bounding Box" : "Show Bounding Box")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    .accessibilityLabel(showBoundingBox ? "Hide the bounding box overlay" : "Show the bounding box overlay")
                    
                    Spacer()
                }
                Spacer()
                
                // Overlay for inspection results
                if showInspection && !inspectionResults.isEmpty {
                    VStack {
                        Text("Geometry Inspection Results:")
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.8))
                            .font(.headline)
                            .padding(.bottom, 8)
                        ScrollView {
                            Text(inspectionResults)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.9))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 200)
                        
                        Button("Close") {
                            showInspection = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(8)
                        .accessibilityLabel("Close inspection results")
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
    
    private func loadResourceFiles() {
        // Load .scn files dynamically from the app bundle
        resourceFiles = (Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: nil) ?? [])
            .map { $0.lastPathComponent }
            .sorted()
        
        // Ensure selectedFile is valid; default to first if "newFighter.scn" not found
        if !resourceFiles.contains(selectedFile), let firstFile = resourceFiles.first {
            selectedFile = firstFile
        }
    }
    
    private func inspectGeometry() {
        // Generate report via SceneModel
        inspectionResults = viewModel.sceneModel.generateInspectionReport(for: selectedFile)
        showInspection = true
        
        // Print the full inspection results to console (matches UI)
        print("Geometry Inspection Results:\n\(inspectionResults)")
        
        // Print summary to console for debugging
        viewModel.sceneModel.printGeometrySummary()
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
