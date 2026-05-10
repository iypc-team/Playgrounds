// GPT_MotionEnabled 05/10/2026-1
// ContentView.swift
// GPT_MotionEnabled.swiftpm
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT_MotionEnabled.swiftpm
// 
// 

import SwiftUI

struct ContentView: View {
    
    @StateObject
    private var viewModel = SceneViewModel()
    
    var body: some View {
        
        ZStack {
            
            SceneKitView(
                scene: viewModel.combatScene,
                allowsCameraControl:
                    !viewModel.isMotionActive
            )
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                // iOS 16.6-compatible Picker implementation.
                // The iOS 17 `.onChange(of:) { oldValue, newValue in }`
                // overload does not exist on iOS 16.
                
                Picker(
                    "Ship",
                    selection: $viewModel.selectedShip
                ) {
                    
                    ForEach(ShipType.allCases) { ship in
                        
                        Text(ship.displayName)
                            .tag(ship)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                .padding(.top, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .onChange(of: viewModel.selectedShip) { newShip in
                    
                    viewModel.changeShip(to: newShip)
                }
                
                OrientationPanel(
                    orientation:
                        viewModel.orientationState
                )
                .padding(.horizontal)
                
                Spacer()
                
                MotionControls(
                    viewModel: viewModel
                )
                .padding()
            }
            .font(
                .system(
                    size: 14,
                    weight: .semibold,
                    design: .default
                )
            )
            .padding()
        }
        .background(Color.black)
        .onTapGesture(count: 2) {
            
            viewModel.shieldsEnabled.toggle()
        }
        .onDisappear {
            
            viewModel.stopMotion()
        }
    }
}
