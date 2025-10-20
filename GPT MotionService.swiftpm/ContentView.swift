//  GPT MotionService 10/20/2025-initial commit
//  GPT4.1 
//  How to implement  startDeviceMotionUpdates(using: .xMagneticNorthZVertical MVVM paradigm

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        VStack {
            if let q = viewModel.quaternion {
                Text("x: \(q.x)")
                Text("y: \(q.y)")
                Text("z: \(q.z)")
                Text("w: \(q.w)")
            } else {
                Text("Waiting for motion data...")
            }
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}
