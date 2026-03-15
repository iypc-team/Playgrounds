//  Inspect_SCN 03/15/2026-1
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm
//  

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    // File names from Resources directory
    private let resourceFiles = [
        "Y-Up-fighter.scn",
        "fighter.scn",
        "fighterPBR.scn",
        "newFighter.scn",
        "new_enemy.scn",
        "smooth_ship.scn"
    ]
    
    // State for selected file, initialized to match SceneModel's default sceneName
    @State private var selectedFile = "newFighter.scn"
    
    // State for showing inspection results
    @State private var inspectionResults: String = ""
    @State private var showInspection: Bool = false
    
    var body: some View {
        ZStack {
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("3D Fighter Scene")
                .onChange(of: selectedFile) { newValue in
                    viewModel.loadScene(for: newValue)
                    inspectionResults = "" // Reset inspection when scene changes
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
                    
                    // New button for geometry inspection
                    Button(action: {
                        inspectGeometry()
                    }) {
                        Text("Inspect Geometry")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    .tint(.white)
                    
                    Spacer()
                }
                Spacer()
                
                // Overlay for inspection results
                if showInspection && !inspectionResults.isEmpty {
                    VStack {
                        Text("Geometry Inspection Results:")
                            .foregroundColor(.white)
                            .font(.headline)
                        ScrollView {
                            Text(inspectionResults)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
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
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
    
    private func inspectGeometry() {
        // Load scene for inspection if needed
        _ = viewModel.sceneModel.loadSceneForInspection()
        
        // Gather inspection data
        let nodes = viewModel.sceneModel.listAllNodes()
        let geometries = viewModel.sceneModel.listAllGeometries()
        let boundingBox = viewModel.sceneModel.sceneBoundingBox()
        
        var results = "Scene: \(selectedFile)\n"
        results += "Total Nodes: \(nodes.count)\n"
        results += "Nodes with Geometry: \(geometries.count)\n"
        
        if let box = boundingBox {
            results += "Bounding Box: Min(\(box.min.x), \(box.min.y), \(box.min.z)) Max(\(box.max.x), \(box.max.y), \(box.max.z))\n"
        }
        
        results += "\nGeometries:\n"
        for (index, geometry) in geometries.enumerated() {
            results += "\(index + 1). \(geometry.name ?? "Unnamed") - \(type(of: geometry))\n"
        }
        
        inspectionResults = results
        showInspection = true
        
        // Also print to console for debugging
        viewModel.sceneModel.printGeometrySummary()
    }
}

#Preview {
    ContentView()
}
