//  DF22_MotionEnabled 05/06/2026-1
//  ContentView.swift
//  Project:  DF22_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF22_MotionEnabled.swiftpm
//

import SwiftUI
import SceneKit

// 1. Type-safe enum for Ship selections — kept in sync with SceneModel.availableShipNames
enum ShipType: String, CaseIterable, Identifiable {
    case fighter     = "fighter"
    case newFighter  = "newFighter"
    case fighterPBR  = "fighterPBR"
    case smoothShip  = "smooth_ship"
    case airplane    = "airplane"
    case yUpFighter  = "Y-Up-fighter.scn"
    
    var id: String { self.rawValue }
    
    // ✅ Fix #1: All cases already match rawValue — switch was redundant
    var displayName: String { self.rawValue }
}

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    @State private var selectedShip: ShipType = .fighter
    @State private var isMotionActive: Bool = false
    
    var body: some View {
        ZStack {
            SceneKitUIView(
                combatScene: viewModel.combatScene,
                allowsCameraControl: !isMotionActive
            )
            
            VStack {
                Picker("Ship", selection: $selectedShip) {
                    ForEach(ShipType.allCases) { ship in
                        Text(ship.displayName).tag(ship)
                    }
                }
                .pickerStyle(.menu)
                // ✅ Fix #3: Single-argument onChange — required for iOS 16.6 compatibility
                // Note: Two-argument { _, newValue in } form requires iOS 17+
                .onChange(of: selectedShip) { newValue in
                    viewModel.changeShip(to: newValue.rawValue)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        viewModel.startMotion()
                        isMotionActive = true
                    }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                        // ✅ Fix #2: background added so cornerRadius is visible
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                    Button(action: {
                        viewModel.stopMotion()
                        isMotionActive = false
                    }) {
                        Text("Stop Motion")
                            .foregroundColor(.red)
                            .padding()
                        // ✅ Fix #2: background added so cornerRadius is visible
                            .background(Color.black.opacity(0.5))
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
            viewModel.changeShip(to: selectedShip.rawValue)
        }
        .onDisappear {
            viewModel.stopMotion()
            isMotionActive = false
        }
    }
}

struct SceneKitUIView: UIViewRepresentable {
    var combatScene: SCNScene
    var allowsCameraControl: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = combatScene
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.darkGray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // ✅ Fix #4: Guard scene re-assignment — only update if scene object changed
        if scnView.scene !== combatScene {
            scnView.scene = combatScene
        }
        scnView.allowsCameraControl = allowsCameraControl
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
