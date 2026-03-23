// SCN_MotionEnabled 03/23/2026-3
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
        
        ZStack {
            SceneKitView(scene: viewModel.scene)
                .ignoresSafeArea()
            
            VStack {
                Picker("Ship", selection: $viewModel.selectedShip) {
                    ForEach(ships, id: \.self) { ship in
                        Text(ship).tag(ship)
                    }
                }
//                .pickerStyle(.menu)
//                .padding(16)
//                .font(.system(size: 24, weight: .semibold, design: .default))
//                .foregroundColor(.white)
//                .background(Color.clear)
                
                
                Spacer()
                
                HStack {
                    Button("Start Motion") {
                        viewModel.startMotion()
                    }
                    
                    Button("Stop Motion") {
                        viewModel.stopMotion()
                    }
                    
//                    Button("Reset") {
//                        viewModel.resetOrientation()
//                    }
                }
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .background(Color.clear)
            }
        }
        .font(.system(size: 22, weight: .semibold, design: .default))
        .padding(20)
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
