// 
// 

import RealityKit
import MetalKit

/// A thin wrapper around MTKView that knows how to render a RealityKit scene.
final class RealityKitRenderView: MTKView {
    
    // MARK: – Core RealityKit objects
    private var realityScene: RealityKit.Scene?
    private var renderer: Renderer?               // <-- the hidden renderer we obtain from Engine
    private static let engine = Engine()          // Shared Engine (singleton)
    
    // MARK: – Public API
    /// Call this whenever your ViewModel supplies a new Entity.
    func setRootEntity(_ entity: Entity?) {
        guard let entity = entity else { return }
        
        // 1️⃣ Build a fresh RealityKit scene.
        let scene = RealityKit.Scene()
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        scene.addAnchor(anchor)
        
        // 2️⃣ Keep a reference to the scene.
        self.realityScene = scene
        
        // 3️⃣ Create (or recreate) the Renderer for this scene.
        //    The Engine owns the GPU resources; the Renderer draws the scene.
        self.renderer = Self.engine.makeRenderer(for: scene)
        
        // 4️⃣ Tell MTKView to start calling `draw(in:)`.
        self.delegate = self
    }
}

// MARK: – MTKViewDelegate (render loop)
extension RealityKitRenderView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // No special handling needed for a static scene.
    }
    
    func draw(in view: MTKView) {
        guard let renderer = renderer,
              let drawable = view.currentDrawable,
              let commandQueue = view.device?.makeCommandQueue(),
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        // 👉 This is the *public* way to render a RealityKit scene:
        //    The renderer draws directly into the Metal texture supplied by the drawable.
        renderer.render(to: drawable.texture, commandBuffer: commandBuffer)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
