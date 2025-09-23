import SwiftUI
import CoreMotion
import Foundation


class MotionManager: ObservableObject  {
    let motionManager = CMMotionManager()
    @Published var w = 0.0
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    
    init() {
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main, withHandler: {[weak self] data, error in
            guard let motion = data?.attitude.quaternion else {return}
            self?.w = motion.w
            self?.x = motion.x
            self?.y = motion.y
            self?.z = motion.z
        })
        motionManager.deviceMotionUpdateInterval = 10
        
        func startUpdates() {
            print("try to start updates")
            
            
        }
        func stopUpdates() {
            motionManager.stopDeviceMotionUpdates()
        }
        func degreesFromRadians(_ radians: Double) -> Double {
            return radians * 180 / .pi
        }
    }
}

struct ContentView: View {
    @StateObject private var motion = MotionManager()
    var body: some View {
        VStack(alignment: .leading) {
            Text("isAccelerometerAvailable:\t \(motion.motionManager.isAccelerometerAvailable)")
            Text("isGyroAvailable:\t\t\t\t \(motion.motionManager.isGyroAvailable)")
            Text("isMagnetometerAvailable:\t \(motion.motionManager.isMagnetometerAvailable)")
            Text("isDeviceMotionAvailable:\t \(motion.motionManager.isDeviceMotionAvailable)\n")
            
            Text("isAccelerometerActive:\t\(motion.motionManager.isAccelerometerActive)")
            Text("isGyroActive:\t\t\t\t\(motion.motionManager.isGyroActive)")
            Text("isMagnetometerActive:\t\t\t\(motion.motionManager.isMagnetometerActive)")
            Text("isDeviceMotionActive:\t\(motion.motionManager.isDeviceMotionActive)")
                .foregroundStyle(.green)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            
            Text("\n\(motion.w)\tw")
            Text("\(motion.x)\txAxis")
            Text("\(motion.y)\tyAxis")
            Text("\(motion.z)\tzAxis")         
            
            
        }
        Spacer()
        HStack {
            Button("Stop", systemImage: "xmark.octagon.fill", action: motion.motionManager.stopDeviceMotionUpdates)
                .foregroundStyle(.red)
            Spacer()
            Button("Start", systemImage: "octagon.fill", action: motion.motionManager.startDeviceMotionUpdates)
                .foregroundStyle(.green)
                .bold()
        }
    }
}


struct ContentView_Provider: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

