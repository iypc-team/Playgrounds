//  Inspect_SCN 04/13/2026-4
//  ContentView.swift)
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
            // Primary SceneKit view to display 3D content
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
                .onChange(of: selectedFile) { newValue in
                    // Handle file switching by reloading the scene and resetting states
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
                    // Dynamically load .scn files on view presentation
                    loadResourceFiles()
                    if resourceFiles.contains(selectedFile) {
                        viewModel.loadScene(for: selectedFile)
                    } else if let firstFile = resourceFiles.first {
                        selectedFile = firstFile
                        viewModel.loadScene(for: firstFile)
                    }
                }
            
            // Overlayed button menu aligned at the top with a vertical stack
            VStack {
                HStack {
                    Spacer()
                    Menu {
                        // Dynamically populate menu with resource files
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
                    
                    // Inspect Geometry Button
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
                    
                    // List Materials Button
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
                    
                    // Set Materials to Double-Sided Button
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
                    
                    // Set Materials to Reflective Button
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
                    
                    // Randomize Material Colors Button
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
                    
                    // Toggle Bounding Box Button
                    Button(action: {
                        showBoundingBox.toggle()
                        // Toggle logic to display or remove bounding box from the scene
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
                .padding()
                
                Spacer()
                
                // Overlayed inspection results
                if showInspection && !inspectionResults.isEmpty {
                    overlayResultsView(title: "Geometry Inspection Results:", content: inspectionResults) {
                        showInspection = false
                    }
                }
                
                // Overlayed materials results
                if showMaterials && !materialsResults.isEmpty {
                    overlayResultsView(title: "Materials List:", content: materialsResults) {
                        showMaterials = false
                    }
                }
            }
        }
    }
    
    // Dynamically load .scn files from app resources
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
    
    // Inspector overlay for geometry/materials results
    private func overlayResultsView(title: String, content: String, onClose: @escaping () -> Void) -> some View {
        VStack {
            Text(title)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.8))
                .font(.headline)
                .padding(.bottom, 8)
            ScrollView {
                Text(content)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 200)
            Button("Close", action: onClose)
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.7))
                .cornerRadius(8)
                .accessibilityLabel("Close results")
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
    }
    
    // Geometry inspection action
    private func inspectGeometry() {
        print("private func inspectGeometry()")
        inspectionResults = viewModel.sceneModel.generateInspectionReport(for: selectedFile)
        showInspection = true
        print("Geometry Inspection Results:\n\(inspectionResults)")
        viewModel.sceneModel.printGeometrySummary()
    }
    
    // List materials action
    private func listMaterials() {
        print("private func listMaterials()")
        materialsResults = viewModel.sceneModel.generateMaterialsReport(for: selectedFile)
        showMaterials = true
        print("Materials Results:\n\(materialsResults)")
    }
    
    // Toggle materials to double-sided rendering
    private func setAllMaterialsDoubleSided() {
        print("private func setAllMaterialsDoubleSided()")
        viewModel.sceneModel.setAllMaterialsDoubleSided()
        print("All materials set to double-sided.")
    }
    
    // Set materials to very reflective rendering
    private func setAllMaterialsVeryReflective() {
        print("private func setAllMaterialsVeryReflective()")
        viewModel.sceneModel.setAllMaterialsVeryReflective()
        print("All materials set to very reflective.")
    }
    
    // Randomize material colors
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
