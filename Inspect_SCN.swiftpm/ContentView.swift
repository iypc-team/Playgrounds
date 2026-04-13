//  Inspect_SCN 04/13/2026-3
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm

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
    
    // State for showing materials results
    @State private var materialsResults: String = ""
    @State private var showMaterials: Bool = false
    
    var body: some View {
        ZStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
                .onChange(of: selectedFile) { newValue in
                    viewModel.loadScene(for: newValue)
                    inspectionResults = ""
                    showInspection = false
                    materialsResults = ""
                    showMaterials = false
                    // Updated: Explicitly remove bounding box node to prevent accumulation on scene switch
                    viewModel.scene.rootNode.childNode(withName: "boundingBox", recursively: true)?.removeFromParentNode()
                    showBoundingBox = false
                }
                .onAppear {
                    loadResourceFiles()
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
                        listMaterials()
                    }) {
                        Text("List Materials")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    .accessibilityLabel("List all materials in the current scene")
                    
                    Button(action: {
                        setAllMaterialsDoubleSided()
                    }) {
                        Text("Set Double-Sided")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    .accessibilityLabel("Set all materials to double-sided rendering")
                    
                    Button(action: {
                        setAllMaterialsVeryReflective()
                    }) {
                        Text("Set Very Reflective")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    .accessibilityLabel("Set all materials to very reflective")
                    
                    Button(action: {
                        randomizeMaterialColors()
                    }) {
                        Text("Randomize Colors")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    .accessibilityLabel("Randomize colors for all materials")
                    
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
                
                if showMaterials && !materialsResults.isEmpty {
                    VStack {
                        Text("Materials List:")
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.8))
                            .font(.headline)
                            .padding(.bottom, 8)
                        ScrollView {
                            Text(materialsResults)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.9))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 200)
                        
                        Button("Close") {
                            showMaterials = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(8)
                        .accessibilityLabel("Close materials list")
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
    
    private func loadResourceFiles() {
        print("private func loadResourceFiles()")
        // Load .scn files dynamically from the app bundle
        let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: nil) ?? []
        
        // FIX: Use URL-based loading to validate, NOT SCNScene(named:)
        resourceFiles = urls
            .filter { url in
                // Validate that the file can actually be loaded as a SceneKit scene
                do {
                    let _ = try SCNScene(url: url, options: nil)
                    return true
                } catch {
                    print("Warning: '\(url.lastPathComponent)' could not be loaded: \(error.localizedDescription)")
                    return false
                }
            }
            .map { $0.lastPathComponent }
            .sorted()
        
        if resourceFiles.isEmpty {
            print("Error: No loadable .scn files found in the Resources directory.")
        } else {
            if !resourceFiles.contains(selectedFile), let firstFile = resourceFiles.first {
                selectedFile = firstFile
            }
            print("Found loadable .scn files: \(resourceFiles)")
        }
    }
    
    private func inspectGeometry() {
        print("private func inspectGeometry()")
        inspectionResults = viewModel.sceneModel.generateInspectionReport(for: selectedFile)
        showInspection = true
        print("Geometry Inspection Results:\n\(inspectionResults)")
        viewModel.sceneModel.printGeometrySummary()
    }
    
    private func listMaterials() {
        print("private func listMaterials()")
        materialsResults = viewModel.sceneModel.generateMaterialsReport(for: selectedFile)
        showMaterials = true
        print("Materials Results:\n\(materialsResults)")
    }
    
    private func setAllMaterialsDoubleSided() {
        print("private func setAllMaterialsDoubleSided()")
        viewModel.sceneModel.setAllMaterialsDoubleSided()
        print("All materials set to double-sided.")
    }
    
    private func setAllMaterialsVeryReflective() {
        print("private func setAllMaterialsVeryReflective()")
        viewModel.sceneModel.setAllMaterialsVeryReflective()
        print("All materials set to very reflective.")
    }
    
    private func randomizeMaterialColors() {
        print("private func randomizeMaterialColors()")
        viewModel.sceneModel.setAllMaterialsRandomColors()
        print("Material colors randomized.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
