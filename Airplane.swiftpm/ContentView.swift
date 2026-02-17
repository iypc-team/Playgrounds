//  Airplane  02/17/2026-5
//  ContentView.swift 
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/Airplane.swiftpm
//  

import SwiftUI

enum Axis: Hashable {
    case x, y, z, xy
    
    var vector: SIMD3<Float> {
        switch self {
        case .x: return SIMD3<Float>(1, 0, 0)
        case .y: return SIMD3<Float>(0, 1, 0)
        case .z: return SIMD3<Float>(0, 0, 1)
        case .xy: return SIMD3<Float>(1, 1, 0)
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = AirplaneViewModel()
    @State private var airplaneModel: AirplaneModel?
    @State private var loadError: String?
    
    @State private var isContinuousRotating: Bool = false
    @State private var continuousAxis: Axis = .y
    @State private var isTargetRotating: Bool = false
    @State private var contactText: String = "No contacts yet"
    
    private let fontSize: CGFloat = 22
    
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
                    isTargetRotating: $isTargetRotating,
                    onContactEvent: { text in
                        contactText = text
                    }
                )
                .ignoresSafeArea()
            } else {
                ProgressView("Loading airplane…")
                    .font(.system(size: fontSize, weight: .medium, design: .default))
                    .tint(.black)   // Updated for better compatibility
                    .foregroundColor(.black)
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Button(isContinuousRotating ? "Stop Airplane Continuous" : "Start Airplane Continuous") {
                        if isContinuousRotating {
                            vm.stopContinuousRotation()
                        } else {
                            vm.startContinuousRotation(axis: continuousAxis.vector, speed: 0.25)
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
                    Text("X-axis").tag(Axis.x)
                    Text("Y-axis").tag(Axis.y)
                    Text("Z-axis").tag(Axis.z)
                    Text("XY-axis").tag(Axis.xy)
                }
                .font(.system(size: fontSize, weight: .bold))
                .pickerStyle(.automatic)
                .padding()
            }
            .font(.system(size: fontSize, weight: .bold))
            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
