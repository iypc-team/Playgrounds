// Lumo MotionService 10/28/2025-3
// CoreMotion attitude quaternion Implementing xMagneticNorthZVertical AsyncThrowingStream MVVM paradigm
// 1f

import SwiftUI
import CoreMotion

struct MotionView: View {
    @StateObject private var vm = MotionViewModel()
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Degrees")
                .font(.headline)
            
            Text("x: \(vm.quaternion.x * 180 / .pi, specifier: "%.1f")°")
            Text("y: \(vm.quaternion.y * 180 / .pi, specifier: "%.1f")°")
            Text("z: \(vm.quaternion.z * 180 / .pi, specifier: "%.1f")°")
            Text("w: \(vm.quaternion.w * 180 / .pi, specifier: "%.1f")°")
            
            Spacer()
            Text("Radians")
                .font(.headline)
            // Show the components nicely
            Text("""
                 x: \(vm.quaternion.x, specifier: "%.1f")
                 y: \(vm.quaternion.y, specifier: "%.1f")
                 z: \(vm.quaternion.z, specifier: "%.1f")
                 w: \(vm.quaternion.w, specifier: "%.1f")
                 """)
            .multilineTextAlignment(.center)
            
            Spacer()
            HStack {
                Button("Start") { vm.start() }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.black)
//                    .background(Color.green)
                
                Button("Stop") { vm.stop() }       .buttonStyle(.bordered)
                    .foregroundColor(.black)
//                    .background(Color.red)
                    
            }
            .padding()
        }
        .padding()
//        .onAppear(perform: {
//            vm.start()
//        })
        .onDisappear(perform: {
            vm.stop()
        })
    }
}

//protocol MotionProviding {
//    func quaternionStream(updateInterval: TimeInterval) -> AsyncThrowingStream<CMQuaternion, Error>
//}
//
//// Conform MotionService to the protocol
//extension MotionService: MotionProviding {}
//
//final class MockMotionService: MotionProviding {
//    func quaternionStream(updateInterval: TimeInterval) -> AsyncThrowingStream<CMQuaternion, Error> {
//        AsyncThrowingStream { continuation in
//            // Emit a few deterministic quaternions then finish
//            continuation.yield(CMQuaternion(x: 0, y: 0, z: 0, w: 1))
//            continuation.yield(CMQuaternion(x: 0.1, y: 0, z: 0, w: 0.995))
//            continuation.finish()
//        }
//    }
//}

//

