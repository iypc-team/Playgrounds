//  LumoMotionService  10/09/2025-1
//  CoreMotion attitude quaternion w,x y,z, values AsyncThrowingStream MVVM paradigm
//  

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
            .multilineTextAlignment(.trailing)
            
            // Example visualisation – a rotating cube
//            CubeView(quaternion: vm.quaternion)
//                .frame(width: 150, height: 150)
        }
        .padding()
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

//
