//  GPT MotionService 10/24/2025-1
//  GPT4.1 
//  How to implement  startDeviceMotionUpdates(using: .xMagneticNorthZVertical MVVM paradigm

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        Spacer()
        VStack {
            Text("deviceMotionActive:  \(viewModel.motionActive)")
              .padding(.vertical, 16)
            if let q = viewModel.quaternion
            {
                Text("x: \(q.x)")                    
                Text("y: \(q.y)")
//                    .padding()
                Text("z: \(q.z)")
                Text("w: \(q.w)")
            } else {
                Text("Waiting for motion data...")
            }
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        
        Spacer()
        HStack {
            Spacer()
            Button(action: {
                print("Start Updates tapped!")
                viewModel.start()
            }) {
                // MARK: – Button label
                Text("Start Updates")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)          // Text colour
                    .padding(.vertical, 8)           // Vertical spacing inside the button
                    .padding(.horizontal, 8)         // Horizontal spacing inside the button
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.green)         // Fill colour
                    )
            }
            Button(action: {
                print("Stop Updates tapped!")
                viewModel.stop()
            }) {
                Text("Stop Updates")
                    .foregroundColor(.white)          // Text colour
                    .padding(.vertical, 8)           // Vertical spacing inside the button
                    .padding(.horizontal, 8)         // Horizontal spacing inside the button
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.red) 
                    )
            }
            Spacer()
        }
        .padding(10)
    }
    
}
