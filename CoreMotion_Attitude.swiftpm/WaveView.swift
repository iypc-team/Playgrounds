//  CoreMotion-2 01/26/2026-2
//  WaveView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/CoreMotion-2.swiftpm
//  
//  1f  0.0f

import SwiftUI

struct WaveView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 12) {
                Text("Attitude XYZ")
                    .font(.headline)
                
                Text("Roll:  \(viewModel.roll, specifier: "%.0.0f")°")
                Text("Pitch: \(viewModel.pitch, specifier: "%.0.0f")°")
                Text("Yaw:   \(viewModel.yaw, specifier: "%.0.0f")°")
            }
            .padding()
            
            // Overlay controls
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    
                    // Start Button
                    Button {
                        viewModel.startUpdates()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.green)
                    
                    // Re-Calibrate Button
                    Button {
                        viewModel.recalibrate()
                    } label: {
                        Label("Re-Cal", systemImage: "location.north.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.yellow)
                    
                    // Stop Button
                    Button {
                        viewModel.stopUpdates()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
    }
}

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
            .preferredColorScheme(.dark)
    }
}

