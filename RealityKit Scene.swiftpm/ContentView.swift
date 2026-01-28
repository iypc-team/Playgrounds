//  RealityKit Scene  01/28/2026 inital commit
//  ContentView.swift
//  
//  
//  

import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        RealityKitView()
            .ignoresSafeArea()
    }
}

struct RealityKitView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(
            frame: .zero,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )
        
        // Background so model contrast is visible
        arView.environment.background = .color(.black)
        
        // Root anchor
        let anchor = AnchorEntity(world: .zero)
        
        // ✅ Correct USDZ loading
        let airplane = try! Entity.load(named: "Airplane")
        
        // ✅ Center model
        let bounds = airplane.visualBounds(relativeTo: nil)
        airplane.position = -bounds.center
        
        // ✅ Auto-scale to reasonable size
        let maxDimension = max(bounds.extents.x,
                               bounds.extents.y,
                               bounds.extents.z)
        let scaleFactor: Float = 1.0 / maxDimension
        airplane.scale = SIMD3(repeating: scaleFactor)
        
        // MARK: - Lighting
        let sun = DirectionalLight()
        sun.light.intensity = 3_000
        sun.orientation = simd_quatf(
            angle: -.pi / 4,
            axis: SIMD3<Float>(1, 0, 0)
        )
        
        let fill = PointLight()
        fill.light.intensity = 3_000
        fill.position = SIMD3<Float>(2, 2, 2)
        
        // MARK: - Camera (CRITICAL)
        let camera = PerspectiveCamera()
        camera.position = SIMD3<Float>(0, 0, 2)
        camera.look(
            at: .zero,
            from: camera.position,
            relativeTo: nil
        )
        
        // Scene graph
        anchor.addChild(airplane)
        anchor.addChild(sun)
        anchor.addChild(fill)
        anchor.addChild(camera)
        
        arView.scene.addAnchor(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
