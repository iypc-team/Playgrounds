//  .1
//  Yaw

import SwiftUI
import CoreMotion

struct MagneticNorthAttitudeView: View {
    @State private var roll: Double = 0.0   // radians
    @State private var pitch: Double = 0.0   // radians
    @State private var yaw: Double = 0.0   // radians
    
    private let manager = CMMotionManager()
    private let reference = CMAttitudeReferenceFrame.xMagneticNorthZVertical
    var updateInterval: TimeInterval = 1.0 / 1
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("(MagneticNorthAttitudeView)")
                .font(.headline)
                
            Text(String(format: "%.1f°", roll * 180 / .pi))
                .font(.largeTitle)
            Text(String(format: "%.1f°", pitch * 180 / .pi))
                .font(.largeTitle)
            Text(String(format: "%.1f°", yaw * 180 / .pi))
                .font(.largeTitle)
            Spacer()
        }
//        .onAppear { startUpdates() }
        .onDisappear { stopUpdates() }
        HStack(content: {
            Button(action: { manager.startQueuedUpdates() }, label: {
                Text("Start\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.green)
                    .padding()
            })
            
            Button(action: { manager.stopMotionUpdates() }, label: {
                Text("Stop\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.red)
                    .padding()
            })
        })
//        Spacer()
//        HStack(alignment: .center, spacing: 20, content: {
//            Button(" startUpdates ", action: startUpdates)
//                .background(Color.green)
//                .foregroundColor(.black)
//            Button(" stopUpdates ", action: stopUpdates)
//                .background(Color.red)
//                .foregroundColor(.black)
//        })
        
        .padding(20)
        .font(.system(size: 22, weight: .regular, design: .default))
    }
    
    private func startUpdates() {
        
        print("startUpdates")
        print(self.reference)
        guard manager.isDeviceMotionAvailable && !manager.isDeviceMotionActive,
              CMMotionManager.availableAttitudeReferenceFrames().contains(reference) else {
            print("Magnetic‑north reference not supported")
            
            return
        }
        manager.deviceMotionUpdateInterval = updateInterval
        manager.startDeviceMotionUpdates(using: reference, to: OperationQueue.main) { motion, _ in
            guard let att = motion?.attitude.quaternion else { return }
            DispatchQueue.main.async {
                print(att)
                self.roll = att.x   // already magnetic‑north referenced
                self.pitch = att.y   // already magnetic‑north referenced
                self.yaw = att.z   // already magnetic‑north referenced
            }
        }
    }
    
    private func stopUpdates() {
        print("stopUpdates")
        manager.stopDeviceMotionUpdates()
        self.roll = 0.0
        self.pitch = 0.0
        self.yaw = 0.0
    }
}
