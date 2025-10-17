// LumoMotionProvider  10/14/2025-1
// CoreMotion attitude quaternion AsyncThrowingStream error handling
// 

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        VStack {
            Text(".  \(viewModel)")
            Spacer()
            if let quaternion = viewModel.quaternion {
                Text("x: \(quaternion.x)")
                Text("y: \(quaternion.y)")
                Text("z: \(quaternion.z)")
                Text("w: \(quaternion.w)")
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
