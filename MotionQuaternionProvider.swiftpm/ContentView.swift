import SwiftUI

struct ContentView: View {
    let mqp = MotionQuaternionProvider()
    
    var body: some View {
        Spacer()
        VStack(alignment: .center, spacing: 40) {
            Text("updateInterval: \(mqp.updateInterval)")
        }
        Spacer()
        HStack(alignment: .center, spacing: 20, content: {
            Button("Start", action: {
                print("Start pressed")
                mqp.manager.startDeviceMotionUpdates()
            })
            .frame(width: 75,height: 30)
            .background(Color.green)
            .foregroundColor(.black)
            
            Button("Pause", action: {
                print("Pause pressed")
            })
            .frame(width: 75,height: 30)
            .background(Color.yellow)
            .foregroundColor(.black)
            
            
            Button("Stop", action: {
                print("Stop pressed")
                mqp.manager.stopDeviceMotionUpdates()
            })
            .frame(width: 75,height: 30)
            .background(Color.red)
            .foregroundColor(.black)
        })
        .font(.system(size: 18, weight: .bold, design: .default))
        .padding(30)
    }
}

//

