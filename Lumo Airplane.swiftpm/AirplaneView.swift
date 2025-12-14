//  Lumo Airplane  12/14/2025-5
/*
 
 https://github.com/iypc-team/Playgrounds/tree/main/Lumo%20Airplane.swiftpm
 
 */
// Start


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
                    Text("Y‑axis").tag(SIMD3<Float>(0, 1, 0))
                    Text("Z‑axis").tag(SIMD3<Float>(0, 0, 1))
                    Text("XY‑axis").tag(SIMD3<Float>(1, 1, 0))
                    Text("All‑axis").tag(SIMD3<Float>(1, 1, 1))
                }
                .pickerStyle(.automatic)
                .padding()
            }
            .font(.system(size: 18, weight: .bold, design: .default))
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
