//     12.3
//   \
import SwiftUI
import Foundation
import GLKit

struct ContentView: View {
    let mdp = MotionDataProvider()
    @StateObject var motionManager = MotionDataProvider()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            
            Spacer()
            Text("x:   \(motionManager.x , specifier: "%12.3f")")  // Roll
                .frame(width: .infinity,height: 30)
                .background(Color.clear)
            
            Text("x:  \(GLKMathRadiansToDegrees(Float(motionManager.x))) degrees")
            
            Text("y:   \(motionManager.y, specifier: "%12.3f")")  // 
                .frame(width: .infinity,height: 30)
                .background(Color.clear)
            
            Text("y:  \(GLKMathRadiansToDegrees(Float(motionManager.y))) degrees")
            
            Text("z:   \(motionManager.z, specifier: "%12.3f")")  // yaw
                .frame(width: .infinity,height: 30)
                .background(Color.clear)
            
            
            Text("w:   \(motionManager.w, specifier: "%12.3f")")
                .frame(width: .infinity,height: 30)
                .background(Color.clear)
            
            
            Spacer()
        }
        .font(.system(size: 18, weight: .medium, design: .default))
        
        VStack(alignment: .leading, spacing: 1) {
            Text("isMotionActive:\t\(String(describing: mdp.motionActive))")
                .frame(width: .infinity,height: 30)
                .background(Color.clear)
            Spacer()
        }
        .font(.system(size: 18, weight: .medium, design: .default))
        
        HStack(content: {
            Button(action: { mdp.startMotionUpdates() }, label: {
                Text("Start\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.green)
                    .padding()
            })
            
            Button(action: { mdp.stopMotionUpdates() }, label: {
                Text("Stop\nUpdate")
                    .cornerRadius(10)
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.red)
                    .padding()
            })
        })
        .onDisappear { mdp.stopMotionUpdates() }
        .padding(.all)
        .font(.system(size: 18, weight: .semibold, design: .default))
        
    }
}
