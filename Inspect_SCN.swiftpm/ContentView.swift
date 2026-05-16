//  Inspect_SCN  05/16/2026-2
//  ContentView.swift
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    @State private var resourceFiles: [String] = []
    @State private var selectedFile = "smooth_ship1.scn"
    
    @State private var inspectionResults: String = ""
    @State private var showInspection: Bool = false
    
    @State private var showBoundingBox: Bool = false
    
    @State private var materialsResults: String = ""
    @State private var showMaterials: Bool = false
    
    @State private var showLoadError: Bool = false
    @State private var loadErrorMessage: String = ""
    
    /// Incremented only when the user picks a new file, forcing SceneKitView
    /// to fully tear down and rebuild via `.id()`.
    @State private var sceneRevision: Int = 0
    
    /// Hard-coded fallback list guarantees the Menu is fully populated even
    /// when Swift Playgrounds' bundle enumeration is incomplete at launch.
    private let fallbackSceneFiles: [String] = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighterPBR.scn",
        "newFighter.scn",
        "pyramid.scn",
        "smooth_ship1.scn",
        "smooth_ship.scn",
        "sphere.scn"
    ]
    
    // Export states
    @State private var exportFormat: String = "usdz"
    @State private var showExportSuccess: Bool = false
    @State private var exportedURL: URL? = nil
    
    var body: some View {
        ZStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .id(sceneRevision)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Scene Viewer")
            
            VStack {
                // MARK: - Toolbar (Extracted)
                ToolbarView(
                    selectedFile: $selectedFile,
                    showBoundingBox: $showBoundingBox,
                    resourceFiles: resourceFiles,
                    exportFormat: $exportFormat,
                    onInspectGeometry: inspectGeometry,
                    onListMaterials: listMaterials,
                    onSetDoubleSided: setAllMaterialsDoubleSided,
                    onSetVeryReflective: setAllMaterialsVeryReflective,
                    onBoundingBoxToggle: toggleBoundingBox,
                    onExport: exportCurrentScene
                )
                
                Spacer()
                resultsOverlays
            }
        }
        // ✅ .onAppear and .onChange are intentionally on the ZStack
        .onAppear {
            loadResourceFiles()
            
            let fileToLoad = resourceFiles.contains(selectedFile) 
            ? selectedFile 
            : (resourceFiles.first ?? selectedFile)
            
            if fileToLoad != selectedFile {
                selectedFile = fileToLoad
            }
            
            // Fixed: Use the return value to suppress the warning
            let _ = viewModel.loadScene(for: fileToLoad)
        }
        .onChange(of: selectedFile) { newValue in
            resetInspectionState()
            let success = viewModel.loadScene(for: newValue)
            sceneRevision += 1
            
            if !success {
                loadErrorMessage = "Failed to load '\(newValue)'. The file may be corrupt or incompatible."
                showLoadError = true
            }
        }
        .alert("Scene Load Error", isPresented: $showLoadError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(loadErrorMessage)
        }
        .alert("Export Successful", isPresented: $showExportSuccess) {
            Button("OK") { }
            if let url = exportedURL {
                Button("Copy Full Path") {
                    UIPasteboard.general.string = url.path
                }
            }
        } message: {
            Text("Saved as:\n\(exportedURL?.lastPathComponent ?? "unknown")\n\nFolder: Exports")
        }
    }
    
    // MARK: - Results Overlays
    @ViewBuilder
    private var resultsOverlays: some View {
        if showInspection && !inspectionResults.isEmpty {
            overlayResultsView(title: "Geometry Inspection Results:", content: inspectionResults) {
                showInspection = false
            }
        }
        if showMaterials && !materialsResults.isEmpty {
            overlayResultsView(title: "Materials List:", content: materialsResults) {
                showMaterials = false
            }
        }
    }
    
    private func overlayResultsView(title: String, content: String,
                                    onClose: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
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
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.red.opacity(0.7))
                .cornerRadius(8)
                .accessibilityLabel("Close results")
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
    }
    
    // MARK: - Resource Discovery
    private func loadResourceFiles() {
        print("\n[loadResourceFiles]")
        var found = Set<String>(fallbackSceneFiles)
        
        if let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: nil) {
            urls.forEach { found.insert($0.lastPathComponent) }
        }
        if let urls = Bundle.main.urls(forResourcesWithExtension: "scn", subdirectory: "Resources") {
            urls.forEach { found.insert($0.lastPathComponent) }
        }
        
        if let bundleURL = Bundle.main.resourceURL {
            let fm = FileManager.default
            fm.enumerator(at: bundleURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)?
                .compactMap { $0 as? URL }
                .filter { $0.pathExtension.lowercased() == "scn" }
                .forEach { found.insert($0.lastPathComponent) }
        }
        
        if let rp = Bundle.main.resourcePath {
            let fm = FileManager.default
            (try? fm.contentsOfDirectory(atPath: rp))?
                .filter { $0.lowercased().hasSuffix(".scn") }
                .forEach { found.insert($0) }
            
            let sub = (rp as NSString).appendingPathComponent("Resources")
            if fm.fileExists(atPath: sub) {
                (try? fm.contentsOfDirectory(atPath: sub))?
                    .filter { $0.lowercased().hasSuffix(".scn") }
                    .forEach { found.insert($0) }
            }
        }
        
        resourceFiles = found.sorted()
        print("[loadResourceFiles] Found: \(resourceFiles)")
        
        if !resourceFiles.contains(selectedFile), let first = resourceFiles.first {
            selectedFile = first
        }
    }
    
    // MARK: - Actions
    private func resetInspectionState() {
        inspectionResults = ""
        showInspection = false
        materialsResults = ""
        showMaterials = false
        showBoundingBox = false
        
        viewModel.scene.rootNode
            .childNode(withName: "boundingBox", recursively: true)?
            .removeFromParentNode()
    }
    
    private func inspectGeometry() {
        print("[inspectGeometry]")
        inspectionResults = viewModel.sceneModel.generateInspectionReport(for: selectedFile)
        showInspection = true
        viewModel.sceneModel.printGeometrySummary()
    }
    
    private func listMaterials() {
        print("[listMaterials]")
        materialsResults = viewModel.sceneModel.generateMaterialsReport(for: selectedFile)
        showMaterials = true
    }
    
    private func setAllMaterialsDoubleSided() {
        print("[setAllMaterialsDoubleSided]")
        viewModel.sceneModel.setAllMaterialsDoubleSided()
    }
    
    private func setAllMaterialsVeryReflective() {
        print("[setAllMaterialsVeryReflective]")
        viewModel.sceneModel.setAllMaterialsVeryReflective()
    }
    
    private func toggleBoundingBox() {
        showBoundingBox.toggle()
        if showBoundingBox {
            if let boxNode = viewModel.sceneModel.createBoundingBoxNode() {
                viewModel.scene.rootNode.addChildNode(boxNode)
            }
        } else {
            viewModel.scene.rootNode
                .childNode(withName: "boundingBox", recursively: true)?
                .removeFromParentNode()
        }
    }
    
    private func exportCurrentScene() {
        if let url = viewModel.exportScene(as: selectedFile, format: exportFormat) {
            exportedURL = url
            showExportSuccess = true
        }
    }
}

// MARK: - Toolbar Label Style

extension Text {
    func styledToolbarLabel(background color: Color) -> some View {
        self
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(color.opacity(0.5))
            .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
