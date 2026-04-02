//  DF_MotionEnabled 03/31/2026-3
//  ContentView.swift
//  Project:  DF_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF_MotionEnabled.swiftpm
//  

import SwiftUI
import SceneKit
// import CoreMotion  // Removed: Not directly used in this view; assumed used in SceneViewModel

// Define ship types as an enum for better maintainability and type safety
enum ShipType: String, CaseIterable {
    case fighter, newFighter, fighterPBR, smooth_ship, airplane, yUpFighter = "Y-Up-fighter.scn"
    
    var displayName: String {
        switch self {
        case .fighter:    return "Fighter"
        case .newFighter: return "New Fighter"
        case .fighterPBR: return "Fighter PBR"
        case .smooth_ship: return "Smooth Ship"
        case .airplane:   return "Airplane"
        case .yUpFighter: return "Y-Up Fighter"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    @State private var selectedShip: ShipType = .fighter
    
    var body: some View {
        ZStack {
            SceneKitUIView(combatScene: viewModel.combatScene)
            
            VStack {
                Picker("Ship", selection: $selectedShip) {
                    ForEach(ShipType.allCases, id: \.self) { ship in
                        Text(ship.displayName).tag(ship)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedShip) { newValue in
                    viewModel.changeShip(to: newValue.rawValue)
                }
                .padding(.horizontal)
                .accessibilityLabel("Select a ship model")
                
                Spacer()
                
                HStack {
                    Button(action: { viewModel.startMotion() }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 1))
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Start motion simulation")
                    .accessibilityHint("Begins device motion integration for the scene")
                    
                    Button(action: { viewModel.stopMotion() }) {
                        Text("Stop Motion")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Stop motion simulation")
                    .accessibilityHint("Stops device motion integration for the scene")
                }
                .padding()
                .font(.system(size: 20, weight: .semibold, design: .default))  // Moved to specific container
            }
        }
        .onTapGesture(count: 2) {
            viewModel.shieldsEnabled.toggle()
            // Removed debug print; use logging if needed
        }
        .onAppear {
            viewModel.changeShip(to: selectedShip.rawValue)
        }
    }
}

struct SceneKitUIView: UIViewRepresentable {
    var combatScene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = combatScene
        // Moved static configurations here to avoid redundant updates
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.darkGray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Optimized: Only update scene if it has changed
        if scnView.scene !== combatScene {
            scnView.scene = combatScene
        }
        // Dynamic updates can be added here if needed (e.g., conditional settings)
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
