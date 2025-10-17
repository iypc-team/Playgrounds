// GPTThrowingStream-2  10/17/2025-1
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
            Spacer()
            
            Button(action: {
                // Your tap‑handler goes here
                print("Start Updates tapped!")
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
                // Your tap‑handler goes here
                print("Stop Updates tapped!")
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
        
        .font(.system(size: 18, weight: .heavy, design: .default))
        .onAppear {
            // The ViewModel will start streaming as soon as the view appears
        }
        .onDisappear {
            // Optionally handle cleanup or stop streaming here
        }
    }
}

//


