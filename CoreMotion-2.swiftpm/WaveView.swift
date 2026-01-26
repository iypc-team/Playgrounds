//  CoreMotion-2 01/25/2026-4
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
                
                Text("Roll:  \(viewModel.roll, specifier: "%.1f")°")
                Text("Pitch: \(viewModel.pitch, specifier: "%.1f")°")
                Text("Yaw:   \(viewModel.yaw, specifier: "%.1f")°")
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
                    
                    // Re-Calibrate Button
                    Button {
                        viewModel.recalibrate()
                    } label: {
                        Label("Re-Calibrate", systemImage: "location.north.fill")
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Stop Button
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

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
            .preferredColorScheme(.dark)
    }
}

