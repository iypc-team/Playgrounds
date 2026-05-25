// GPT_MotionEnabled 05/25/2026-4
// ContentView.swift
// iOS 16.6+ compatible
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/GPT_MotionEnabled.swiftpm 

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @StateObject private var viewModel = SceneViewModel()
    @State private var showDebugFullScreen = false
    @State private var dragOffset: CGFloat = 0.0
    
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
                    
                    // UI Overlay
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
    // FIX 1: Removed value.velocity.width — DragGesture.Value.velocity requires iOS 17+.
    //         Replaced with value.predictedEndTranslation.width as a momentum proxy
    //         (available since iOS 13).
    // FIX 2: Replaced #Preview macro (Xcode 15 / iOS 17+) with PreviewProvider (iOS 13+).
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 80)
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let distance = value.translation.width
                // predictedEndTranslation reflects momentum and is iOS 13+ compatible
                let predicted = value.predictedEndTranslation.width
                
                // Swipe right → show debug
                if distance > 120 || predicted > 220 {
                    showDebugFullScreen = true
                }
                // Swipe left → hide debug
                else if distance < -120 || predicted < -220 {
                    showDebugFullScreen = false
                }
                
                dragOffset = 0
            }
    }
}

// FIX 2: #Preview macro requires Xcode 15+ / iOS 17+.
//         Use PreviewProvider for iOS 16.6 compatibility.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
