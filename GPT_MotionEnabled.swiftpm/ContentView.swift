// GPT_MotionEnabled 05/11/2026-2
// ContentView.swift
// GPT_MotionEnabled.swiftpm
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT_MotionEnabled.swiftpm
//
// Fix #4 — Updated MotionControls call site to match new decoupled initializer.
// Fix #8 — Removed stale `import os` and commented-out AppLogger call.

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
                
                // Fix #4: Pass only what MotionControls needs —
                // a Bool and two action closures — instead of the full ViewModel.
                MotionControls(
                    isMotionActive: viewModel.isMotionActive,
                    onStart: { viewModel.startMotion() },
                    onStop:  { viewModel.stopMotion()  }
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
