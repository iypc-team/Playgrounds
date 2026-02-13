//  Airplane  02/12/2026-2
//  ContentView.swift 
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Airplane.swiftpm
//  

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    @State private var loadError: String?
    
    // Incremental pinch-to-scale (no snapping each new gesture)
    @State private var baseScale: CGFloat = 1.0
    @GestureState private var pinchScale: CGFloat = 1.0
    @State private var isContinuousRotating: Bool = false
    @State private var continuousAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0) // default Y
    @State private var isTargetRotating: Bool = false
    @State private var contactText: String = "No contacts yet"
    
    private let fontSize: CGFloat = 22
    private let scaleRange: ClosedRange<CGFloat> = 0.125...10.1
    
    private var effectiveScale: CGFloat {
        (baseScale * pinchScale).clamped(to: scaleRange)
    }
    
    var body: some View {
        //        print("ContentView body called")
        ZStack {
            if let error = loadError {
                Text("Failed to load airplane: \(error)")
                    .foregroundColor(.blue)
                    .padding()
            } else if let model = airplaneModel {
                ARViewContainer(
                    airplaneEntity: model.entity,
                    viewModel: vm,
                    scale: .constant(effectiveScale),
                    isTargetRotating: $isTargetRotating,
                    onContactEvent: { text in
                        contactText = text
                    }
                )
                .ignoresSafeArea()
            } else {
                ProgressView("Loading airplane…")
                    .font(.system(size: fontSize, weight: .medium, design: .default))
                    .tint(.black)
                    .foregroundColor(.black)
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Button(isContinuousRotating ? "Stop Airplane Continuous" : "Start Airplane Continuous") {
                        if isContinuousRotating {
                            vm.stopContinuousRotation()
                        } else {
                            vm.startContinuousRotation(axis: continuousAxis, speed: 0.25)
                        }
                        isContinuousRotating.toggle()
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button(isTargetRotating ? "Stop Target Rotation" : "Start Target Rotation") {
                        isTargetRotating.toggle()
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
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
            
            // Contact overlay
            VStack {
                Text(contactText)
                    .font(.system(size: fontSize, weight: .semibold))
                    .padding(8)
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 12)
                Spacer()
            }
        }
        .gesture(
            MagnificationGesture()
                .updating($pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    print("value: \(value)")
                    baseScale = (baseScale * value).clamped(to: scaleRange)
                    print("baseScale: \(baseScale)")
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

#Preview {
    ContentView()
}
