// Attitude_2 04/28/2026-1
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/Attitude_2.swiftpm
// 
// 1f  0.0f

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        ZStack {
            // Removed: Color.black.ignoresSafeArea() - handled by LandscapeRightViewController
            
            VStack(spacing: 20) {
                Spacer(minLength: 24)
                
                // Display section for Roll, Pitch, and Yaw
                VStack(spacing: 12) {
                    Text("Attitude XYZ")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Roll:  \(viewModel.roll,  specifier: "%.0f")°")
                        .foregroundColor(.white)
                    
                    Text("Pitch: \(viewModel.pitch, specifier: "%.0f")°")
                        .foregroundColor(.white)
                    
                    Text("Yaw:   \(viewModel.yaw,   specifier: "%.0f")°")
                        .foregroundColor(.white)
                    
                    // Streaming status indicator
                    Text(viewModel.isStreaming ? "Streaming" : "Stopped")
                        .font(.footnote)
                        .foregroundColor(viewModel.isStreaming ? .green : .gray)
                        .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 12) {
                    // Start streaming motion data
                    Button {
                        viewModel.startStream()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                    
                    // Recalibrate motion sensor
                    Button {
                        viewModel.recalibrate()
                    } label: {
                        Label("Re-Cal", systemImage: "location.north.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.yellow)
                    .buttonStyle(.borderedProminent)
                    
                    // Stop streaming motion data
                    Button {
                        Task {
                            await viewModel.stopStream()
                        }
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding()
            }
        }
        // Ensure streaming is stopped when the view disappears
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
