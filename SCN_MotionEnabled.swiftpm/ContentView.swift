// SCN_MotionEnabled 03/23/2026-4
// ContentView.swift
// Project: SCN_MotionEnabled.swiftpm
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SCN_MotionEnabled.swiftpm
// 

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @StateObject private var viewModel = SceneViewModel()
    
    private let ships = [
        "fighter",
        "newFighter",
        "fighterPBR",
        "smooth_ship",
        "newEnemy",
        "Y-Up-fighter"
    ]
    
    var body: some View {
        
        ZStack {
            SceneKitView(scene: viewModel.scene)
                .ignoresSafeArea()
            
            VStack {
                Menu {
                    ForEach(ships, id: \.self) { ship in
                        Button(ship) {
                            viewModel.selectedShip = ship
                        }
                    }
                } label: {
                    Text("Ship: \(viewModel.selectedShip)")
                        
                }
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .background(Color.clear)
                .padding(20)
                
                
                Spacer()
                
                HStack {
                    Button("Start Motion") {
                        viewModel.startMotion()
                    }
                    .padding(20)
                    Button("Stop Motion") {
                        viewModel.stopMotion()
                    }
                    .padding(20)
                    
                }
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .background(Color.clear)
                .padding(20)
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
