// LumoMotionProvider  10/25/2025-2
// CoreMotion attitude quaternion AsyncThrowingStream error handling
// rad * 180 / .pi
//   °

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        VStack {
            Text(".  \(viewModel)")
            Spacer()
            if let quaternion = viewModel.quaternion {
                Text("x: \(quaternion.x * 180 / .pi, specifier: "%.1f")°")
                Text("y: \(quaternion.y * 180 / .pi, specifier: "%.1f")°")
                Text("z: \(quaternion.z * 180 / .pi, specifier: "%.1f")°")
                Text("w: \(quaternion.w * 180 / .pi, specifier: "%.1f")°")
            } else {
                Text("No data available")
            }
            Spacer()
        }
        .onAppear {
            viewModel.startUpdates()
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
    }
}

//import SwiftUI
//import CoreMotion
//
//struct ContentView: View {
//    @StateObject private var viewModel = MotionViewModel()
//    
//    var body: some View {
//        VStack {
//            Text("Quaternion:")
//                .font(.headline)
//            Text(viewModel.quaternionString)
//                .monospacedDigit()
//                .padding()
//        }
//        .onAppear { viewModel.start() }
//        .onDisappear { viewModel.stop() }
//    }
//}
//
//
