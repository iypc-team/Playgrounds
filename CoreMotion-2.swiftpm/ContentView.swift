import SwiftUI
import CoreMotion

let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

struct WaveView: View {
    var motionManager = CMMotionManager()
    
    @State private var attitudeX : Double = 0
    @State private var attitudeY : Double = 0
    @State private var attitudeZ : Double = 0
    
    var body : some View {
        VStack{
            Text("Attitude XYZ")
            Text("")
            Text("Roll  \(attitudeX)")
            Text("Pitch  \(attitudeY)")
            Text("Yaw  \(attitudeX)")
            
        }
        .onReceive(timer) { input in
            print(motionManager.isDeviceMotionAvailable)
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 2.0
                
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { data,error in
                    print("Attitude XYZ")
 

                    print("\nAttitude")
                    print(data?.attitude.debugDescription ?? 0)
                    print(data?.attitude.pitch ?? 0)
                    print(data?.attitude.roll ?? 0)
                    print(data?.attitude.yaw ?? 0)

                }
            }
        }
    }
}                

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
    }
}

