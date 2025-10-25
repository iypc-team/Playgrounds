//  LumoMotionService-2  10/25/2025-1
//  CoreMotion attitude quaternion w,x y,z, values AsyncThrowingStream MVVM paradigm
//  .1f

import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @StateObject private var vm = MotionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quaternion")
                .font(.headline)
            
            Text("""
                w: \(vm.quaternion.w, specifier: "%.1f")
                x: \(vm.quaternion.x, specifier: "%.1f")
                y: \(vm.quaternion.y, specifier: "%.1f")
                z: \(vm.quaternion.z, specifier: "%.1f")
                """)
            .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}
