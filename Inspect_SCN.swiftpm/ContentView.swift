//  Inspect_SCN 04/15/2026-2
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
    
    // State for load error alert
    @State private var showLoadError: Bool = false
    @State private var loadErrorMessage: String = ""
    
    var body: some View {
        ZStack {
            // Primary SceneKit view to display 3D content
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
                .onChange(of: selectedFile) { newValue in
                    // Handle file switching by reloading the scene and resetting states
                    let success = viewModel.loadScene(for: newValue)
                    inspectionResults = ""
                    showInspection = false
                    materialsResults = ""
                    showMaterials = false
                    // Explicitly remove bounding box node to prevent accumulation on scene switch
                    viewModel.scene.rootNode.childNode(withName: "boundingBox", recursively: true)?.removeFromParentNode()
                    showBoundingBox = false
                    
                    if !success {
                        loadErrorMessage = "Failed to load '\(newValue)'. The file may be corrupt or incompatible."
                        showLoadError = true
                    }
                }
                .onAppear {
                    // Dynamically load .scn files on view presentation
                    loadResourceFiles()
                    if resourceFiles.contains(selectedFile) {
                        let _ = viewModel.loadScene(for: selectedFile)
                    } else if let firstFile = resourceFiles.first {
                        selectedFile = firstFile
                        let _ = viewModel.loadScene(for: firstFile)
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
        .alert("Scene Load Error", isPresented: $showLoadError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(loadErrorMessage)
        }
    }
    
    // MARK: - Dynamically load .scn files from app resources
    // Uses multiple search strategies to find all .scn files in the bundle,
    // including those with spaces in filenames and those nested in subdirectories
    // by SPM's .process("Resources") directive.
    private func loadResourceFiles() {
        print("private func loadResourceFiles()")
        
        var foundFiles = Set<String>()
        
        // Strategy 1: Search top-level bundle (subdirectory: nil)
        if let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: nil) {
            for url in urls {
                foundFiles.insert(url.lastPathComponent)
            }
        }
        
        // Strategy 2: Search common SPM resource subdirectory names
        // SPM .process("Resources") can place files under the module's resource bundle
        let possibleSubdirectories = ["Resources", ""]
        for subdir in possibleSubdirectories {
            let searchDir = subdir.isEmpty ? nil : subdir
            if let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: searchDir) {
                for url in urls {
                    foundFiles.insert(url.lastPathComponent)
                }
            }
        }
        
        // Strategy 3: Recursively walk the entire bundle to catch any .scn file
        // regardless of where SPM placed it (handles spaces, percent-encoding, etc.)
        if let bundlePath = Bundle.main.resourceURL {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(at: bundlePath,
                                                       includingPropertiesForKeys: nil,
                                                       options: [.skipsHiddenFiles]) {
                while let fileURL = enumerator.nextObject() as? URL {
                    if fileURL.pathExtension.lowercased() == "scn" {
                        foundFiles.insert(fileURL.lastPathComponent)
                    }
                }
            }
        }
        
        resourceFiles = foundFiles.sorted()
        
        if resourceFiles.isEmpty {
            print("Error: No .scn files found in the bundle.")
        } else {
            if !resourceFiles.contains(selectedFile), let firstFile = resourceFiles.first {
                selectedFile = firstFile
            }
            print("Found .scn files: \(resourceFiles)")
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
