// GPTThrowingStream  10/10/2025-1
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
            Button(action: { viewModel.startListeningForMotionData() }, label: {
                Text("Start\nUpdates")
            })
            .frame(width: 100,height: 50)
            .foregroundColor(.black)
            .background(Color.green)
            .padding()
            
            Button(action: {  }, label: {
                Text("Stop\nUpdates")
            })
            .frame(width: 100,height: 50)
            .foregroundColor(.black)
            .background(Color.red)
            .padding()
        }
        .onAppear { } // will start streaming as soon as the view appears 
        .onDisappear {  } // handle cleanup or stop streaming here
    }
}

//
