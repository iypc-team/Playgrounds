//  CP RealityKit  11/16/2025-1
// 

import SwiftUI
import MetalKit

struct SpaceshipContentView: View {
    @StateObject private var vm = SpaceshipViewModel()
    
    var body: some View {
        GeometryReader { geo in
            RealityKitRenderContainer(entity: vm.spaceshipEntity)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)   // optional background colour
        }
    }
}

// MARK: – UIKit bridge (UIViewRepresentable)
struct RealityKitRenderContainer: UIViewRepresentable {
    var entity: Entity?
    
    func makeUIView(context: Context) -> RealityKitRenderView {
        // Create the MTKView with the system default Metal device.
        let view = RealityKitRenderView(frame: .zero,
                                        device: MTLCreateSystemDefaultDevice())
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.clearColor = MTLClearColorMake(0, 0, 0, 1)
        return view
    }
    
    func updateUIView(_ uiView: RealityKitRenderView, context: Context) {
        // Whenever the ViewModel publishes a new entity, hand it to the renderer.
        uiView.setRootEntity(entity)
    }
}
