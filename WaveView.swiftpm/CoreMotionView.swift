// Sample using CoreMotion and SwiftUI to help understand how to use CMMotionManager and CoreMotion to get values of gravity, user acceleration, heading (2), attitude (pitch, roll, yaw), magnetic field
// based on this beautiful example https://github.com/gsachin/DynamicFontRandD/blob/e4f7cc611d1d23573b4026bcc291bee60bf60e91/FontTextStrok/WaveView.swift
// that uses BAFluidView https://github.com/antiguab/BAFluidView
// timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

import SwiftUI
import CoreMotion 

let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct WaveView: View {
    var motionManager = CMMotionManager()
    var motionService = MotionServiceAdater()
    
    @State private var gravityX : Double = 0
    @State private var gravityY : Double = 0
    @State private var gravityZ : Double = 0
    @State private var Position : String = "Move Me"
    
    var body : some View {
        VStack{
            Text("Gravity XYZ")
            Text("\(gravityX)")
            Text("\(gravityY)")
            Text("\(gravityZ)")
            Text(Position)
            Text("Position: \(Position)")
            Spacer()
            HStack  {
                Button("Start", action: {
                    motionManager.startGyroUpdates()
                })
                .foregroundColor(.green)
//                .font(.system(size: 22, weight: .black, design: .default))
                Button("Stop All", action: {
                    motionService.stopStream()
                    print("stopStream()")
                    motionService.stopMonitoring()
                    motionManager.stopGyroUpdates()
                    motionManager.stopMagnetometerUpdates()
                    motionManager.stopAccelerometerUpdates()
                    motionManager.stopDeviceMotionUpdates()
                })
                .foregroundColor(.cardinalRed)
            }
            .font(.system(size: 22, weight: .black, design: .default))
        }
        .onReceive(timer) { input in
            print("isDeviceMotionAvailable: ", motionManager.isDeviceMotionAvailable)
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.3
                
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { data,error in
                    print("Gravity XYZ")
                    gravityX = data?.gravity.x ?? 0
                    gravityY = data?.gravity.y ?? 0
                    gravityZ = data?.gravity.z ?? 0
                    
                    if gravityX < -0.9
                    {
                        Position = "Standing + Landscape + Speaker Left"
                    }
                    else if gravityX > 0.9
                    {
                        Position = "Standing + Landscape + Speaker Right"
                    }
                    else if gravityY < -0.9
                    {
                        Position = "Standing + Portrait + Speaker Up"
                    }
                    else if gravityY > 0.9
                    {
                        Position = "Standing + Portrait + Speaker Down"
                    }
                    else if gravityZ < -0.9
                    {
                        Position = "Flat + Facing Up"
                    }
                    else if gravityZ > 0.9
                    {
                        Position = "Flat + Facing Down"
                    }
                    else
                    {
                        Position = "Not at right angles"
                    }
                    
                    print(data?.gravity.x ?? 0)
                    print(data?.gravity.y ?? 0)
                    print(data?.gravity.z ?? 0)
                    print("User Acceleration")
                    print(data?.userAcceleration.x ?? 0)
                    print(data?.userAcceleration.y ?? 0)
                    print(data?.userAcceleration.z ?? 0)
                    print("Heading")
                    print(data?.heading.debugDescription ?? 0)
                    print(data?.heading.magnitude ?? 0)
                    print(data?.heading.sign ?? 0)
                    print("Attitude")
                    print(data?.attitude.debugDescription ?? 0)
                    print(data?.attitude.pitch ?? 0)
                    print(data?.attitude.roll ?? 0)
                    print(data?.attitude.yaw ?? 0)
                    print("Magnetic Field")
                    print(data?.magneticField.field.x ?? 0)
                    print(data?.magneticField.field.y ?? 0)
                    print(data?.magneticField.field.z ?? 0)
                }
            }
        }
    }
}

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
    }
}d

