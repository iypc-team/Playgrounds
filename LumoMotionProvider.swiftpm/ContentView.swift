// LumoMotionProvider  09/28/2025-1
// CoreMotion attitude Quaternion asyncstream
// 

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        VStack {
            Text("Quaternion:")
                .font(.headline)
            Text(viewModel.quaternionString)
                .monospacedDigit()
                .padding()
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}


