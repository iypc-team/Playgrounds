//  SwiftUIMotionTemplate  09/07/2025-1
//  

import SwiftUI
import CoreMotion

class MotionDataProvider: ObservableObject {
    private let motionProvider = CMMotionManager()
    
    @Published var x = 0.0
    @Published var y = 0.0
    
    init() {
        motionProvider.deviceMotionUpdateInterval = 1 / 20
        motionProvider.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] data, error in
            guard let motion = data?.attitude else { return }
            
            self?.x = motion.roll
            self?.y = motion.pitch
        }
    }
}

struct ContentView: View {
    // 1.
    @StateObject private var motionManager = MotionDataProvider()
    
    var body: some View {
        // 2.
        VStack {
            Text("Create with Swift")
                .font(.system(size: 40).bold())
            
            ZStack{
                Circle().frame(width: 200) //.shadow(radius: 8)
                
                Image(systemName: "swift")
                    .font(.system(size: 100).bold())
            }
        }
        // 3.
        .foregroundStyle(
            .white.gradient.shadow(
                .inner(color: .forestGreen, radius: 6, x: motionManager.x * -20, y: motionManager.y * -20)
            )
        )
        // 4.
        .rotation3DEffect(.degrees(motionManager.x * 20), axis: (x: 0, y: 1, z: 0))
        .rotation3DEffect(.degrees(motionManager.y * 20), axis: (x: -1, y: 0, z: 0))
        
    }
}
