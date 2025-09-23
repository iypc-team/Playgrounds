//  QuaternionMotion  09/01/2025-2
//  
//  
import SwiftUI
import CoreMotion
import Foundation
import PlaygroundSupport


struct ContentView: View { 
    let mdp = MotionDataProvider()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("  ")
            Text("1 radian = \(mdp.degreesFromRadians(radians: 1), specifier: "%12.14F")°")
            
            Text("isDeviceMotionAvailable:  \(MotionDataProvider.motionProvider!.isDeviceMotionAvailable)")
            
            Text("isDeviceMotionActive:  \(MotionDataProvider.motionProvider!.isDeviceMotionActive)")
            
            Spacer()
        }
        .font(.system(size: 18, weight: .regular, design: .default))
        
        VStack(alignment: .center, spacing: 8) {
            
            Text("x: \(mdp.x, specifier: "%12.3f")")
            Text("y: \(mdp.y, specifier: "%12.3f")")
            Text("z: \(mdp.z, specifier: "%12.3f")")
            Text("heading: \(mdp.heading, specifier: "%12.3f")")
            Spacer()
        }
        .font(.system(size: 18, weight: .regular, design: .default))
        
        HStack(content: {
            Button(action: { MotionDataProvider.motionProvider!.startDeviceMotionUpdates() }, label: {
                Text("Start\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.green)
                    .padding()
            })
            
            Button(action: { MotionDataProvider.motionProvider!.stopDeviceMotionUpdates() }, label: {
                Text("Stop\nUpdate")
                    .frame(width: 100,height: 50)
                    .cornerRadius(20)
                    .foregroundColor(.black)
                    .background(Color.red)
                    .padding()
            })
        })
        .onDisappear(perform: {
            MotionDataProvider.motionProvider!.stopDeviceMotionUpdates()
        })
        .padding(.all)
        .font(.system(size: 18, weight: .semibold, design: .default))
    }
}

//class MotionManager: ObservableObject { 
//    let mgr: CMMotionManager = CMMotionManager()
//    
//    var quat: CMQuaternion = CMQuaternion()
//    
//    @Published var x = 0.0
//    @Published var y = 0.0
//    @Published var z = 0.0
//    @Published var w = 0.0
//    @Published var motionActive = false
//    @Published var updateInterval = 2.0
//    
//    init() {
//        startDeviceMotionUpdates()
//        
//        self.x = x  // .roll
//        self.y = y  // .pitch
//        self.z = z  // .yaw
//        self.w = w  // .wtf
//    }
//    
//    public func startDeviceMotionUpdates() {
//        print("private func startDeviceMotionUpdates()")
//        if mgr.isDeviceMotionAvailable {
//            
//            let queue = OperationQueue()
//            queue.name = "Queue-1"
//            queue.qualityOfService = QualityOfService.userInitiated
//            
//            print("queue.name: \(String(describing: queue.name))")
//            print("queue.qualityOfService: \(queue.qualityOfService) ")
//            
//            mgr.deviceMotionUpdateInterval = updateInterval
//            mgr.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: queue, withHandler: { (motion, error) in
//                guard let motion = motion else { return }
//                self.quat = motion.attitude.quaternion
//                self.motionActive = self.mgr.isDeviceMotionActive
//            })
//            print("quat: \(String(describing: quat))")
//            print("isDeviceMotionActive: \(mgr.isDeviceMotionActive)\n")
//        }
//    }
//    
//    public func stopDeviceMotionUpdates() {
//        print("public func stopDeviceMotionUpdates()")
//        mgr.stopDeviceMotionUpdates()
//        self.motionActive = self.mgr.isDeviceMotionActive
//        print("isDeviceMotionActive: \(self.mgr.isDeviceMotionActive)\n")
//    }
//    
//    public func degreesFromRadians(_ radians: Double) -> Double {
//        return radians * 180 / .pi
//    }
//}


