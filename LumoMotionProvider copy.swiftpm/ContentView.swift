// LumoMotionProvider  09/28/2025-1
// CoreMotion attitude quaternion AsyncThrowingStream error handling
// 

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        VStack {
            Text("Quaternion:")
                .font(.headline)
            Text(viewModel.quat)
                .monospacedDigit()
                .padding()
        }
        .onAppear { viewModel.getStream() }
        .onDisappear { viewModel.stopStream() }
    }
}


