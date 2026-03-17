//  Inspect_SCN 03/17/2026-1
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm

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
    
    private func inspectGeometry() {
        // Generate report via SceneModel
        inspectionResults = viewModel.sceneModel.generateInspectionReport(for: selectedFile)
        showInspection = true
        
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
