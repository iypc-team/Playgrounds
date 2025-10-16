// GPTThrowingStream  10/15/2025-1
// CoreMotion attitude quaternion AsyncThrowingStream MVVM Paradigm
//  quaternion

import SwiftUI
// ContentView
struct ContentView: View {
    @StateObject var viewModel = MotionViewModel()
    let mm = MotionModel()
    
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
        Spacer()
        HStack {
            Button(action: { mm.getAttitudeStream() }, label: {
                Text("Start\nUpdates")
            })
            .padding(10)
            .foregroundColor(.black)
            .background(Color.green)
            
            Button(action: { mm }, label: {
                Text("Stop\nUpdates")
            })
            .padding(10)
            .foregroundColor(.black)
            .background(Color.red)
            
        }
        .padding(10)
        .onAppear {
            // The ViewModel will start streaming as soon as the view appears
        }
        .onDisappear {
            // Optionally handle cleanup or stop streaming here
        }
    }
}

//


