//  Lumo Airplane  12/14/2025-3
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Lumo%20Airplane.swiftpm
 */
// 

import SwiftUI

struct AirplaneView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    @State private var sliderTimer: DispatchWorkItem?  // Timer for debouncing slider prints
    
    var body: some View {
        ZStack {
            // ---------- RealityKit scene ----------
            if let model = airplaneModel {
                ARViewContainer(airplaneEntity: model.entity, viewModel: vm)
                    .ignoresSafeArea()
            } else {
                // Loading placeholder
                ProgressView("Loading airplane…")
            }
            // print
            // ---------- UI overlay (optional) ----------
            VStack {
                Spacer()
                Slider(value: Binding(
                    get: { Double(vm.revolutionsPerSecond) },
                    set: { newValue in
                        // Cancel any pending print
                        sliderTimer?.cancel()
                        
                        // Schedule a new print after 0.5 seconds of inactivity
                        let workItem = DispatchWorkItem {
                            print("Final slider value: \(Int(newValue))")  // Print as integer
                        }
                        sliderTimer = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: workItem)
                        
                        // Update the view model
                        vm.revolutionsPerSecond = Float(newValue)
                    }
                ), in: 0...5, step: 1, label: { Text("Speed") })  // Added step: 1 for integer snapping
                .padding(.horizontal)
                
                Text("vm.revolutionsPerSecond: \(vm.revolutionsPerSecond) ")
                
                // Example: change axis with a picker
                Picker("Axis", selection: $vm.rotationAxis) {
                    Text("X‑axis").tag(SIMD3<Float>(1, 0, 0))
                    Text("Y‑axis").tag(SIMD3<Float>(0, 1, 0))
                    Text("Z‑axis").tag(SIMD3<Float>(0, 0, 1))
                    Text("All‑axis").tag(SIMD3<Float>(1, 1, 1))
                }
                .pickerStyle(.automatic)
                .padding()
            }
        }
        .task {
            // Load the USDZ model once when the view appears.
            do {
                airplaneModel = try await AirplaneModel.load()
            } catch {
                print("❌ Failed to load Airplane.usdz – \(error)")
            }
        }
    }
}
