//  DF22_MotionEnabled 05/07/2026-3
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
            
            VStack(spacing: 12) {
                // Ship Picker
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
                
                // Orientation Indicators
                OrientationPanel(viewModel: viewModel)
                    .padding(.horizontal)
                
                Spacer()
                
                // Motion Controls
                HStack {
                    Button(action: {
                        viewModel.startMotion()
                        isMotionActive = true
                    }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .disabled(isMotionActive)
                    
                    Button(action: {
                        viewModel.stopMotion()
                        isMotionActive = false
                    }) {
                        Text("Stop Motion")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .disabled(!isMotionActive)
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

// MARK: - Orientation Panel
struct OrientationPanel: View {
    @ObservedObject var viewModel: SceneViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Device Orientation")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                IndicatorView(title: "Roll",  value: viewModel.roll,  unit: "°", color: .orange)
                IndicatorView(title: "Pitch", value: viewModel.pitch, unit: "°", color: .cyan)
                IndicatorView(title: "Yaw",   value: viewModel.yaw,   unit: "°", color: .purple)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct IndicatorView: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.1f%@", value * 180 / .pi, unit))
                .font(.title2.monospacedDigit().bold())
                .foregroundColor(color)
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
