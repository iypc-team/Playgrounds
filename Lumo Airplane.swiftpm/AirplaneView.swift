//  Lumo Airplane  12/13/2025-2
/*
 https://github.com/iypc-team/Playgrounds/tree/main/Lumo%20Airplane.swiftpm
*/

import SwiftUI

struct AirplaneView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    
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
            
            // ---------- UI overlay (optional) ----------
            VStack {
                Spacer()
                Slider(value: Binding(
                    get: { Double(vm.revolutionsPerSecond) },
                    set: { vm.revolutionsPerSecond = Float($0) }
                ), in: 0...1, label: { Text("Speed") })
                .padding(.horizontal)
                
                // Example: change axis with a picker
                Picker("Axis", selection: $vm.rotationAxis) {
                    Text("X‑axis").tag(SIMD3<Float>(1, 0, 0))
                    Text("Y‑axis").tag(SIMD3<Float>(0, 1, 0))
                    Text("Z‑axis").tag(SIMD3<Float>(0, 0, 1))
                }
                .pickerStyle(.segmented)
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
