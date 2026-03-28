//  SCN_MotionEnabled 03/28/2026-10
//  ContentView.swift
//  Project:  SCN_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/SCN_MotionEnabled.swiftpm
//  

// Import necessary libraries
import SwiftUI
import SceneKit
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    
    // This computed property dynamically fetches resources from the Resources directory
    var availableResources: [String] {
        guard let urls = Bundle.module.urls(forResourcesWithExtension: "scn", subdirectory: "Resources") else { return [] }
        return urls.map { $0.deletingPathExtension().lastPathComponent }.sorted()
    }
    
    var body: some View {
        ZStack {
            SceneKitUIView(combatScene: viewModel.combatScene)
            
            VStack {
                Picker("Models", selection: $viewModel.selectedShip) {
                    ForEach(availableResources, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                
                Spacer()
                
                // Control buttons
                HStack {
                    Button(action: { viewModel.startMotion() }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { viewModel.stopMotion() }) {
                        Text("Stop Motion")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .font(.system(size: 20, weight: .semibold))
        }
        .onAppear {
            viewModel.changeShip(to: viewModel.selectedShip)
        }
    }
}

// UIViewRepresentable wrapper for SCNView to integrate SceneKit with SwiftUI
struct SceneKitUIView: UIViewRepresentable {
    var combatScene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = combatScene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = combatScene
        // Configure the view for better rendering
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.darkGray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
