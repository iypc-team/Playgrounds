// GPT_MotionEnabled 05/12/2026-3
// ContentView.swift
// GPT_MotionEnabled.swiftpm
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT_MotionEnabled.swiftpm

// ContentView.swift - iOS 16.6 Compatible

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @StateObject private var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            // 3D Scene
            SceneKitView(
                scene: viewModel.combatScene,
                allowsCameraControl: !viewModel.isMotionActive,
                preset: viewModel.performancePreset,
                viewModel: viewModel
            )
            .ignoresSafeArea()
            
            // UI Overlay
            VStack(spacing: 16) {
                
                // Top Controls
                HStack {
                    // Ship Selector
                    Picker("Ship", selection: $viewModel.selectedShip) {
                        ForEach(ShipType.allCases) { ship in
                            Text(ship.displayName).tag(ship)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    
                    Spacer()
                    
                    // Quality Preset
                    Picker("Quality", selection: $viewModel.performancePreset) {
                        ForEach(PerformancePreset.allCases) { preset in
                            Text(preset.displayName).tag(preset)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Orientation Panel
                OrientationPanel(orientation: viewModel.orientationState)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                
                Spacer()
                
                // Bottom Controls
                HStack(spacing: 16) {
                    Button {
                        if viewModel.isMotionActive {
                            viewModel.stopMotion()
                        } else {
                            viewModel.startMotion()
                        }
                    } label: {
                        Label(
                            viewModel.isMotionActive ? "Stop Motion" : "Start Motion",
                            systemImage: viewModel.isMotionActive ? "pause.circle.fill" : "play.circle.fill"
                        )
                        .font(.title2)
                    }
                    .foregroundStyle(viewModel.isMotionActive ? .red : .green)
                    
                    Button("Reset Orientation") {
                        viewModel.resetOrientation()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.vertical, 40)
        }
        .background(Color.black)
        
        // Gestures
        .onTapGesture(count: 2) {
            viewModel.shieldsEnabled.toggle()
        }
        
        // Ship change handler (iOS 16 compatible)
        .onChange(of: viewModel.selectedShip) { newShip in
            viewModel.changeShip(to: newShip)
        }
        
        // Cleanup
        .onDisappear {
            viewModel.stopMotion()
        }
    }
}

#Preview {
    ContentView()
}
