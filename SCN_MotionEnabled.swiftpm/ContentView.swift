// SCN_MotionEnabled 03/23/2026-2
// ContentView.swift
// Project: SCN_MotionEnabled.swiftpm
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SCN_MotionEnabled.swiftpm

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @StateObject private var viewModel = SceneViewModel()
    
    private let ships = [
        "fighter",
        "newFighter",
        "fighterPBR",
        "fighterPBR 1",
        "smooth_ship",
        "newEnemy",
        "Y-Up-fighter"
    ]
    
    var body: some View {
        
        VStack {
            
            SceneKitView(scene: viewModel.scene)
            
            Picker("Ship", selection: $viewModel.selectedShip) {
                ForEach(ships, id: \.self) { ship in
                    Text(ship).tag(ship)
                }
            }
            .pickerStyle(.menu)
            .padding()
            
            HStack {
                
                if viewModel.motionRunning {
                    Button("Stop Motion") {
                        viewModel.stopMotion()
                    }
                } else {
                    Button("Start Motion") {
                        viewModel.startMotion()
                    }
                }
                
                Button("Reset") {
                    viewModel.resetOrientation()
                }
            }
            .font(.system(size: 22, weight: .semibold, design: .default))
            
            if viewModel.shieldsEnabled {
                Text("Shields ON")
                    .foregroundColor(.green)
            } else {
                Text("Shields OFF")
                    .foregroundColor(.red)
            }
            
        }
        .onTapGesture(count: 2) {
            viewModel.toggleShields()
        }
        .onChange(of: viewModel.selectedShip) { newValue in
            viewModel.loadShip(named: newValue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
