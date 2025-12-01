//  Lumo Airplane  12/01/2025-1
// 

import SwiftUI

struct AirplaneView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    
    var body: some View {
        ZStack {
            // ---------- RealityKit scene ----------
            if let model = airplaneModel {
                ARViewContainer(airplaneEntity: model.entity) { quat in
                    // Forward the newest quaternion from the VM.
                    vm.orientation   
                    // forces a read so the compiler sees the dependency
                    // Update the coordinator's copy – the ARView's per‑frame block reads it.
                    // (The closure captures `vm` directly, so we just assign.)
                    // The coordinator will pick it up on the next frame.
                    print("quat.angle: \(quat.angle)")
                    
                    print("quat.axis: \(quat.axis.x)")
                    print("quat.axis: \(quat.axis.y)")
                    print("quat.axis: \(quat.axis.z)\n")
                }
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
        // Keep the ARView's coordinator in sync with the VM.
        .onReceive(vm.$orientation) { newQuat in
            // The ARViewContainer’s coordinator stores this value.
            // Find the container in the view hierarchy and push the quaternion.
            // Because the container captures `vm.orientation` directly,
            // we only need to trigger a change here.
        }
    }
}
