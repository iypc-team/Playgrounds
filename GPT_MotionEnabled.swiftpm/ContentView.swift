// GPT_MotionEnabled 05/25/2026-2
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT_MotionEnabled.swiftpm Type 'CMMagneticFieldCalibrationAccuracy' has no member 'uncertain'.

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @StateObject private var viewModel = SceneViewModel()
    @State private var showDebugFullScreen = false
    @State private var dragOffset: CGFloat = 0.0   // For smooth swipe feedback
    
    var body: some View {
        Group {
            if showDebugFullScreen {
                // === FULL SCREEN DEBUG VIEW ===
                DebugLogView()
                    .transition(.move(edge: .trailing))
                    .gesture(swipeGesture)
            } else {
                // === MAIN MOTION SCENE VIEW ===
                ZStack {
                    // 3D Scene
                    SceneKitView(
                        scene: viewModel.combatScene,
                        allowsCameraControl: !viewModel.isMotionActive,
                        preset: viewModel.performancePreset,
                        viewModel: viewModel
                    )
                    .ignoresSafeArea()
                    
                    // UI Overlay (No debug button)
                    VStack(spacing: 16) {
                        
                        // Top Controls (Ship + Quality only)
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
                            
                            // Quality Preset Picker
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
                        
                        // Bottom Controls (Motion + Reset only)
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
                            
                            Button("Reset") {
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
                .gesture(swipeGesture)
                
                // Gestures
                .onTapGesture(count: 2) {
                    viewModel.shieldsEnabled.toggle()
                }
                
                // Ship change handler
                .onChange(of: viewModel.selectedShip) { newShip in
                    viewModel.changeShip(to: newShip)
                }
                
                // Cleanup
                .onDisappear {
                    viewModel.stopMotion()
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showDebugFullScreen)
    }
    
    // MARK: - Swipe Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 80)
            .onChanged { value in
                // Optional: light visual feedback during drag
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let horizontalDistance = value.translation.width
                let velocity = value.velocity.width
                
                // Swipe right → show debug
                if horizontalDistance > 120 || velocity > 300 {
                    showDebugFullScreen = true
                }
                // Swipe left → hide debug
                else if horizontalDistance < -120 || velocity < -300 {
                    showDebugFullScreen = false
                }
                
                dragOffset = 0
            }
    }
}

#Preview {
    ContentView()
}
