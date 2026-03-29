//  SCN_MotionEnabled 03/29/2026-1
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
    
    // This computed property fetches available models from SceneModel for reliability
    var availableResources: [String] {
        SceneModel.availableShipNames.map { name in
            name.hasSuffix(".scn") ? String(name.dropLast(4)) : name
        }.sorted()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            SceneKitUIView(combatScene: viewModel.combatScene)
                .ignoresSafeArea()
            
            VStack {
                Picker("Models", selection: $viewModel.selectedShip) {
                    ForEach(availableResources, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                .background(Color.white.opacity(0.8))  // Added for visibility on dark background
                .cornerRadius(8)  // Added for consistency
                
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
            .background(Color.black.opacity(0.5))  // Added for better contrast over the scene
        }
        .onAppear {
            viewModel.changeShip(to: viewModel.selectedShip)
        }
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
