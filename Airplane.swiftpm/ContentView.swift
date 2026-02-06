//  Airplane  02/06/2026-4
//  AirplaneView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Airplane.swiftpm

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    @State private var loadError: String?
    @State private var scale: CGFloat = 1.0  // New state for entity scaling
    @State private var isContinuousRotating: Bool = false  // New state for toggle
    
    let fontSize: CGFloat = CGFloat(22)
    
    var body: some View {
        ZStack {
            if let error = loadError {
                Text("Failed to load airplane: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if let model = airplaneModel {
                ARViewContainer(airplaneEntity: model.entity, viewModel: vm, scale: $scale)  // Pass scale binding
                    .ignoresSafeArea()
            } else {
                // Loading placeholder
                ProgressView("Loading airplane…")
            }
            
            VStack {
                Spacer()
                
                // New toggle button for continuous rotation (now above "Start Rotation")
                Button(isContinuousRotating ? "Stop Continuous" : "Start Continuous") {
                    if isContinuousRotating {
                        vm.stopContinuousRotation()
                    } else {
                        vm.startContinuousRotation(axis: vm.rotationAxis, speed: 1.0)  // Use selected axis
                    }
                    isContinuousRotating.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Button to start the stepped rotation
                Button("Start Rotation") {
                    vm.beginTiming()
                }
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Example: change axis with a picker
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
