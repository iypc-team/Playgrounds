//  Airplane  02/07/2026-8
//  AirplaneView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Airplane.swiftpm

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    @State private var loadError: String?
    
    // Incremental pinch-to-scale (no snapping each new gesture)
    @State private var baseScale: CGFloat = 1.0
    @GestureState private var pinchScale: CGFloat = 1.0
    
    @State private var isContinuousRotating: Bool = false
    @State private var continuousAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0) // default Y axis
    
    private let fontSize: CGFloat = 22
    private let scaleRange: ClosedRange<CGFloat> = 0.25...3.0
    
    private var effectiveScale: CGFloat {
        (baseScale * pinchScale).clamped(to: scaleRange)
    }
    
    var body: some View {
        ZStack {
            if let error = loadError {
                Text("Failed to load airplane: \(error)")
                    .foregroundColor(.blue)
                    .padding()
            } else if let model = airplaneModel {
                ARViewContainer(
                    airplaneEntity: model.entity,
                    viewModel: vm,
                    scale: .constant(effectiveScale)
                )
                .ignoresSafeArea()
            } else {
                ProgressView("Loading airplane…")
                    .foregroundColor(.black)
                    .tint(.blue)
            }
            
            VStack {
                Spacer()
                
                Button(isContinuousRotating ? "Stop Continuous" : "Start Continuous") {
                    if isContinuousRotating {
                        vm.stopContinuousRotation()
                    } else {
                        vm.startContinuousRotation(axis: continuousAxis, speed: 0.25)
                    }
                    isContinuousRotating.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Picker("Continuous Axis", selection: $continuousAxis) {
                    Text("X-axis").tag(SIMD3<Float>(1, 0, 0))
                    Text("Y-axis").tag(SIMD3<Float>(0, 1, 0))
                    Text("Z-axis").tag(SIMD3<Float>(0, 0, 1))
                    Text("XY-axis").tag(SIMD3<Float>(1, 1, 0))
                }
                .font(.system(size: fontSize, weight: .bold))
                .pickerStyle(.automatic)
                .padding()
            }
            .font(.system(size: fontSize, weight: .bold))
        }
        .gesture(
            MagnificationGesture()
                .updating($pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    baseScale = (baseScale * value).clamped(to: scaleRange)
                }
        )
        .task {
            do {
                airplaneModel = try await AirplaneModel.load()
            } catch {
                loadError = error.localizedDescription
                print("❌ Failed to load Airplane.usdz – \(error)")
            }
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
