//  DF22_MotionEnabled 05/02/2026-3
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
    case fighterPBR  = "fighterPBR"   // ✅ Fix #3: Uncommented to match SceneModel.availableShipNames
    case smoothShip  = "smooth_ship"
    case airplane    = "airplane"
    case yUpFighter  = "Y-Up-fighter.scn"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .smoothShip:  return "smooth_ship"
        case .yUpFighter:  return "Y-Up-fighter.scn"
        default:           return self.rawValue
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    @State private var selectedShip: ShipType = .fighter
    // ✅ Fix #2: Track motion state to toggle allowsCameraControl
    @State private var isMotionActive: Bool = false
    
    var body: some View {
        ZStack {
            SceneKitUIView(
                combatScene: viewModel.combatScene,
                allowsCameraControl: !isMotionActive  // ✅ Fix #2: Disable camera control during motion
            )
            
            VStack {
                Picker("Ship", selection: $selectedShip) {
                    ForEach(ShipType.allCases) { ship in
                        Text(ship.displayName).tag(ship)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedShip) { newValue in
                    viewModel.changeShip(to: newValue.rawValue)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        viewModel.startMotion()
                        isMotionActive = true   // ✅ Fix #2: Disable allowsCameraControl
                    }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                            .cornerRadius(8)
                    }
                    Button(action: {
                        viewModel.stopMotion()
                        isMotionActive = false  // ✅ Fix #2: Re-enable allowsCameraControl
                    }) {
                        Text("Stop Motion")
                            .foregroundColor(.red)
                            .padding()
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
    var allowsCameraControl: Bool  // ✅ Fix #2: Passed in as a parameter
    
    // ✅ Fix #1: Static SCNView configuration moved to makeUIView — only runs once
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
    
    // ✅ Fix #1: Only dynamic properties updated here
    // ✅ Fix #2: allowsCameraControl toggled based on motion state
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = combatScene
        scnView.allowsCameraControl = allowsCameraControl
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
