//  MotionManager copy  09/24/2025-1
// 
// 
import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var mgr = MotionManager()
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            Text("(ContentView)")
                .font(.headline)
            Text("w: \(mgr.w, specifier: "%12.4f")")
            Text("x: \(mgr.x, specifier: "%12.4f")")
            Text("y: \(mgr.y, specifier: "%12.4f")")
            Text("z: \(mgr.z, specifier: "%12.4f")")
            
            Spacer()
            Text(" roll: \(mgr.roll, specifier: "%12.4f")")
            Text("pitch: \(mgr.pitch, specifier: "%12.4f")")
            Text("  yaw: \(mgr.yaw, specifier: "%12.4f")")
            Spacer()
        }
        .font(.system(size: 18, weight: .bold, design: .default))
        
        HStack(content: {
            Button(action: { mgr.startQueuedUpdates() }, label: {
                Text("Start\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.green)
                    .padding()
            })
            
            Button(action: { mgr.stopMotionUpdates() }, label: {
                Text("Stop\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.red)
                    .padding()
            })
        })
        .font(.system(size: 18, weight: .bold, design: .default))
        

    }
}


//
