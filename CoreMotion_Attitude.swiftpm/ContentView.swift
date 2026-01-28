//  CoreMotion_Attitude  01/28/2026-3
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/blob/main/CoreMotion_Attitude.swiftpm
//  
//  1f  0.0f

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("Attitude XYZ")
                    .font(.headline)
                
                Text("Roll:  \(viewModel.roll,  specifier: "%.0f")°")
                Text("Pitch: \(viewModel.pitch, specifier: "%.0f")°")
                Text("Yaw:   \(viewModel.yaw,   specifier: "%.0f")°")
            }
            .padding()
            
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    
                    Button {
                        viewModel.startStream()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.green)
                    
                    Button {
                        viewModel.recalibrate()
                    } label: {
                        Label("Re-Cal", systemImage: "location.north.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.yellow)
                    
                    Button {
                        Task {
                            await viewModel.stopStream()
                        }
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
        .task {
            // Why: ties CoreMotion lifetime to the view’s visibility
            viewModel.startStream()
        }
        .onDisappear {
            Task {
                await viewModel.stopStream()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
