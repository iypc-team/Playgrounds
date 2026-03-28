//  SCN_MotionEnabled 03/28/2026-8
//  ContentView.swift
//  Project:  SCN_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/SCN_MotionEnabled.swiftpm
//  

// ContentView.swift
// Updated to reflect dynamic picture list based on continents.

// Import necessary libraries
import SwiftUI
import SceneKit
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    
    // This computed property dynamically fetches resources categorized by continent
    var availableResources: [String] {
        let continents = ["asia", "europe", "america", "africa", "australia", "antarctica"]
        var resources = [String]()
        
        for continent in continents {
            guard let urls = Bundle.module.urls(forResourcesWithExtension: "scn", subdirectory: "Resources/\(continent)") else { continue }
            resources.append(contentsOf: urls.map { $0.deletingPathExtension().lastPathComponent })
        }
        
        return resources.sorted()
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
                .onChange(of: viewModel.selectedShip) { newValue in
                    viewModel.changeShip(to: newValue)
                }
                
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
