//  DF22_MotionEnabled 05/02/2026-1
//  ContentView.swift
//  Project:  DF22_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF22_MotionEnabled.swiftpm
//  

import SwiftUI
import SceneKit

// 1. Created a type-safe enum for Ship selections to remove magic strings
enum ShipType: String, CaseIterable, Identifiable {
    case fighter = "fighter"
    case newFighter = "newFighter"
//    case fighterPBR = "fighterPBR"
    case smoothShip = "smooth_ship"
    case airplane = "airplane"
    case yUpFighter = "Y-Up-fighter.scn"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .smoothShip: return "smooth_ship"
        case .yUpFighter: return "Y-Up-fighter.scn"
        default: return self.rawValue
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
                // 2. Used ForEach over the enum cases
                Picker("Ship", selection: $selectedShip) {
                    ForEach(ShipType.allCases) { ship in
                        Text(ship.displayName).tag(ship)
                    }
                }
                .pickerStyle(.menu)
                // 3. iOS 16.6 Compliant onChange handler 
                .onChange(of: selectedShip) { newValue in
                    viewModel.changeShip(to: newValue.rawValue)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Button(action: { viewModel.startMotion() }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                            .cornerRadius(8) // Removed unnecessary .background(Color.clear)
                    }
                    Button(action: { viewModel.stopMotion() }) {
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
        
        // Note: allowsCameraControl allows touch rotation. 
        // If device motion handles rotation, consider disabling this during motion tracking.
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
