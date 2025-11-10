// 
// 

// AirplaneView.swift

import SwiftUI
import RealityKit

import SwiftUI
import RealityKit

struct AirplaneView: View {
    @StateObject var viewModel = AirplaneViewModel()
    private let arView = ARView(frame: .zero) // Direct ARView instance
    
    var body: some View {
        ZStack {
            RealityKitView(viewModel: viewModel, arView: arView)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Slider(value: Binding(
                        get: { viewModel.airplaneModel.scale },
                        set: { viewModel.scaleModel($0) }
                    ), in: 0.5...2.0, label: {
                        Text("Scale")
                    })
                    
                    Spacer()
                    
                    Button("Move Forward") {
                        let newPosition = viewModel.airplaneModel.position + SIMD3<Float>(0, 0, -0.5)
                        viewModel.moveModel(to: newPosition)
                    }
                }
                .padding()
            }
        }
    }
}


