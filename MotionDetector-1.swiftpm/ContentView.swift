import SwiftUI
import Foundation

struct Motion {
    func printInfo() {
        print(ValueMgr.motionMgr.started())
    }
    
    //    func start() {
    //        MotionDetector.motionManager.startDeviceMotionUpdates()
    //        print("stoping motion updates")
    //    }
    //    
    //    func stop() {
    //        MotionDetector.motionManager.stopDeviceMotionUpdates()
    //        print("stoping motion updates")
    //    }
}

struct ValueMgr {
    static let motionMgr = MotionDetector(updateInterval: 2)
    
    func printInfo() {
        print(ValueMgr.motionMgr.started())
    }
}

struct ContentView: View {
    var body: some View {
        
        let intValue = Int(ValueMgr.motionMgr.updateInterval)
        VStack {
        }
        Text("update every : \(intValue) seconds")
            .padding(20)
        Text("pitch:\t  \(ValueMgr.motionMgr.pitch)")
        Text("yaw:\t  \(ValueMgr.motionMgr.yaw)")
        Text("roll:\t  \(ValueMgr.motionMgr.roll)")
        Text("\nzAccel:  \(ValueMgr.motionMgr.zAcceleration)")
        Spacer()
        
        //        .multilineTextAlignment(.center)
        HStack {
            Button("Start", systemImage: "restart.circle.fill", action:ValueMgr.motionMgr.start )
                .foregroundColor(.green)
            
            Spacer()
            
            Button("Stop", systemImage: "stop.fill", action: ValueMgr.motionMgr.stop)
                .foregroundColor(.red)       
        }
        .font(.title)
        .padding(20)
    }
}


