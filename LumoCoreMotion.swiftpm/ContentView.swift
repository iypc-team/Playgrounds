// LumoCoreMotion  10/17/2025-3
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
            Button(action: {
                vm.start()
                print("Start Updates tapped!\n")
            }) {
                // MARK: – Button label
                Text("Start Updates")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)          // Text colour
                    .padding(.vertical, 8)           // Vertical spacing inside the button
                    .padding(.horizontal, 8)         // Horizontal spacing inside the button
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.green)         // Fill colour
                    )
            }
            
            Button(action: {
                vm.stop()
                // Your tap‑handler goes here
                print("Stop Updates tapped!\n")
            }) {
                Text("Stop Updates")
                    .foregroundColor(.white)          // Text colour
                    .padding(.vertical, 8)           // Vertical spacing inside the button
                    .padding(.horizontal, 8)         // Horizontal spacing inside the button
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.red) 
                    )
            }
        })
        .padding()
        .font(.system(size: 18, weight: .regular, design: .default))
    }
}

//
