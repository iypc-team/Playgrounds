//  Airplane  02/06/2026-10
//  AirplaneView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Airplane.swiftpm

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    @State private var loadError: String?
    @State private var scale: CGFloat = 1.0  // New state for entity scaling
    @State private var isContinuousRotating: Bool = false  // New state for toggle
    @State private var continuousAxis: SIMD3<Float> = SIMD3<Float>(1, 0, 0)  // New state for continuous axis (default to Y)
    
    let fontSize: CGFloat = CGFloat(22)
    
    var body: some View {
        ZStack {
            if let error = loadError {
                Text("Failed to load airplane: \(error)")
                    .foregroundColor(.blue)
                    .padding()
            } else if let model = airplaneModel {
                ARViewContainer(airplaneEntity: model.entity, viewModel: vm, scale: $scale)
                    .ignoresSafeArea()
            } else {
                // Loading placeholder
                ProgressView("Loading airplane…")
                    .foregroundColor(.black)
                    .tint(.blue)
            }
            
            VStack {
                Spacer()
                // Toggle button for continuous rotation
                Button(isContinuousRotating ? "Stop Continuous" : "Start Continuous") {
                    if isContinuousRotating {
                        vm.stopContinuousRotation()
                    } else {
                        vm.startContinuousRotation(axis: continuousAxis, speed: 0.25)  // Use selected axis
                    }
                    isContinuousRotating.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Another picker for continuous rotation axis (X, Y, or Z)
                Picker("Continuous Axis", selection: $continuousAxis) {
                    Text("X-axis").tag(SIMD3<Float>(1, 0, 0))
                    Text("Y-axis").tag(SIMD3<Float>(0, 1, 0))
                    Text("Z-axis").tag(SIMD3<Float>(0, 0, 1))
                }
                .font(.system(size: fontSize, weight: .bold, design: .default))
                .pickerStyle(.automatic)
                .padding()
                
                
                // Button to start the stepped rotation
                Button("Start Rotation") {
                    vm.beginTiming()
                }
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Existing picker for stepped rotation axis
                Picker("Axis", selection: $vm.rotationAxis) {
                    Text("X‑axis").tag(SIMD3<Float>(1, 0, 0))
                    Text("Minus X‑axis").tag(SIMD3<Float>(-1, 0, 0))
                    
                    Text("Y‑axis").tag(SIMD3<Float>(0, 1, 0))
                    Text("Minus Y‑axis").tag(SIMD3<Float>(0, -1, 0))
                    
                    Text("Z‑axis").tag(SIMD3<Float>(0, 0, 1))
                    Text("Minus Z‑axis").tag(SIMD3<Float>(0, 0, -1))
                    
                    Text("XY‑axis").tag(SIMD3<Float>(1, 1, 0))
                    Text("Minus XY‑axis").tag(SIMD3<Float>(-1, -1, 0))
                    
                    Text("All‑axis").tag(SIMD3<Float>(1, 1, 1))
                    Text("Minus All‑axis").tag(SIMD3<Float>(-1, -1, -1))
                }
                .font(.system(size: fontSize, weight: .bold, design: .default))
                .pickerStyle(.automatic)
                .padding()
            }
            .font(.system(size: fontSize, weight: .bold, design: .default))
        }
        .gesture(  // Attach pinch gesture to the ZStack
            MagnificationGesture()
                .onChanged { value in
                    scale = value  // Update scale during pinch
                }
        )
        .task {
            // Load the USDZ model once when the view appears.
            do {
                airplaneModel = try await AirplaneModel.load()
            } catch {
                loadError = error.localizedDescription
                print("❌ Failed to load Airplane.usdz – \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
