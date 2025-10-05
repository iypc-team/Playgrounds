// GPTThrowingStream  10/05/2025-5
// CoreMotion attitude quaternion AsyncThrowingStream MVVM Paradigm
//  quaternion

import SwiftUI
// ContentView
struct ContentView: View {
    @StateObject var viewModel = MotionViewModel()
    
    var body: some View {
        VStack {
            if let quaternion = viewModel.quaternion {
                Text("Quaternion: \(quaternion.w), \(quaternion.x), \(quaternion.y), \(quaternion.z)")
                    .padding()
            } else {
                Text("Waiting for motion data...")
                    .padding()
            }
        }
        .onAppear {
            // The ViewModel will start streaming as soon as the view appears
        }
        .onDisappear {
            // Optionally handle cleanup or stop streaming here
        }
    }
}

//
