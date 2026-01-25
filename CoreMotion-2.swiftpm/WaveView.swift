//  CoreMotion-2 01/25/2026-3
//  WaveView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/CoreMotion-2.swiftpm
//  
//. 

import SwiftUI

struct WaveView: View {
    
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        ZStack {
            
            // Main content
            VStack(spacing: 12) {
                Text("Attitude XYZ")
                    .font(.headline)
                
                Text("Roll:  \(viewModel.roll, specifier: "%.3f")")
                Text("Pitch: \(viewModel.pitch, specifier: "%.3f")")
                Text("Yaw:   \(viewModel.yaw, specifier: "%.3f")")
            }
            .padding()
            
            // Overlay controls
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        viewModel.startUpdates()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        viewModel.stopUpdates()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
    }
}


