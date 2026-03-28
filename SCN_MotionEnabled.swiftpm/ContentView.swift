//  SCN_MotionEnabled 03/28/2026-6
//  ContentView.swift
//  Project:  SCN_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/SCN_MotionEnabled.swiftpm
//  

import SwiftUI
import SceneKit
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    
    var availableShips: [String] {
        if let urls = Bundle.module.urls(forResourcesWithExtension: "scn", subdirectory: nil) {
            return urls.map { $0.deletingPathExtension().lastPathComponent }.sorted()
        }
        return []
    }
    
    var body: some View {
        ZStack {
            SceneKitUIView(combatScene: viewModel.combatScene)
            
            VStack {
                Picker("Ship", selection: $viewModel.selectedShip) {
                    ForEach(availableShips, id: \.self) { ship in
                        Text(ship).tag(ship)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.selectedShip) { newValue in
                    viewModel.changeShip(to: newValue)
                }
                .padding(.horizontal)
                
                Spacer()
                
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
            .font(.system(size: 20, weight: .semibold, design: .default))
        }
        .onTapGesture(count: 2) {
            viewModel.shieldsEnabled.toggle()
            print("shieldsEnabled: \(viewModel.shieldsEnabled)")
        }
        .onAppear {
            viewModel.changeShip(to: viewModel.selectedShip)
        }
    }
}

struct SceneKitUIView: UIViewRepresentable {
    var combatScene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = combatScene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = combatScene
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
