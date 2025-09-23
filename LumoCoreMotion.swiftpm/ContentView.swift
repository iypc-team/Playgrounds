//  .1f
// 
// 
import SwiftUI
import CoreMotion

class MotionViewModel: ObservableObject {
    
    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    @Published var heading: Double = 0
    
    private var task: Task<Void, Never>?
    private let provider = MotionProvider(updateInterval: 1.0 / 1.0) // 30 Hz for UI
    
    func start() {
        task = Task {
            for await motion in provider.deviceMotionStream() {
                await MainActor.run {
                    let att = motion.attitude
                    print("motion: \(motion)\n")
                    self.roll = att.roll
                    self.pitch = att.pitch
                    self.yaw = att.yaw
                }
            }
        }
    }
    
    func stop() {
        task?.cancel()
        task = nil
    }
}

struct MotionView: View {
    @StateObject private var vm = MotionViewModel()
    
    var body: some View {
        Spacer()
        VStack(spacing: 12) {
            Text(String(format: "Roll: %.1f°", vm.roll * 180 / .pi))
            Text(String(format: "Pitch: %.1f°", vm.pitch * 180 / .pi))
            Text(String(format: "Yaw: %.1f°", vm.yaw * 180 / .pi))
            Text(String(format: "Heading: %.1f°", vm.heading * 180 / .pi))
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
        .padding()
        .font(.system(size: 18, weight: .regular, design: .default))
        Spacer()
        HStack(content: {
            Button(action: { vm.start() }, label: {
                Text("Start\nUpdate")
                    .frame(width: 100,height: 50)
                    .foregroundColor(.black)
                    .background(Color.green)
                    .padding()
            })
            
            Button(action: { vm.stop() }, label: {
                Text("Stop\nUpdate")
                    .frame(width: 100,height: 50)
                    .cornerRadius(20)
                    .foregroundColor(.black)
                    .background(Color.red)
                    .padding()
            })
        })
        .font(.system(size: 18, weight: .regular, design: .default))
    }
}

//

