//  CoreMotion-2 01/25/2026-2
//  WaveView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/CoreMotion-2.swiftpm
//  
//. 

import SwiftUI

struct WaveView: View {
    
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Attitude XYZ")
                .font(.headline)
            
            Text("Roll:  \(viewModel.roll, specifier: "%.3f")")
            Text("Pitch: \(viewModel.pitch, specifier: "%.3f")")
            Text("Yaw:   \(viewModel.yaw, specifier: "%.3f")")
        }
        .padding()
        .onAppear {
            viewModel.startUpdates()
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
    }
}


