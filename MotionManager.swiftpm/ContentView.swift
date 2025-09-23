//  .1
// 
// 
import SwiftUI

struct ContentView: View {
    @StateObject var mgr = MotionManager()
    
    var body: some View {
        VStack {
            Spacer()
            Text("x: \(mgr.roll)")
            Text("y: \(mgr.pitch)")
            Text("z: \(mgr.yaw)")
            Spacer()
        }
        
        VStack(alignment: .center, spacing: 8) {
            
            Text("x: \(mgr.roll, specifier: "%12.1f")")
            Text("y: \(mgr.pitch, specifier: "%12.1f")")
            Text("z: \(mgr.yaw, specifier: "%12.1f")")
//            Text("heading: \($mgr.heading, specifier: "%12.1f")")
            Spacer()
        }
        .font(.system(size: 18, weight: .regular, design: .default))
        
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
                    .cornerRadius(20)
                    .foregroundColor(.black)
                    .background(Color.red)
                    .padding()
            })
        })
        .font(.system(size: 18, weight: .medium, design: .default))
        .padding(40)
//        HStack {
//            Spacer()
//            Button("Start", systemImage: "restart.circle.fill", action: mgr.startQueuedUpdates )
//                .foregroundColor(.green)
//            
//            Spacer()
//            
//            Button("Stop", systemImage: "stop.fill", action: mgr.stopMotionUpdates)
//                .foregroundColor(.red)
//            Spacer()
//        }
        .font(.system(size: 18, weight: .medium, design: .default))
        .padding(20)
    }
}
