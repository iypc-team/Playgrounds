//  RealityKit Scene  01/29/2026-2
//  ContentView.swift
//  
//  
//  [0.08, 0.15, 0.3, 0.6]
//  rotationSpeed

import SwiftUI
import RealityKit
import Combine

struct ContentView: View {
    
    @State private var rotationSpeed: Float = 0.0
    
    //    private let speeds: [Float] = [0.08, 0.15, 0.3]
    private let speeds: [Float] = [0.0, 0.075, 0.15, 0.25, 0.5 ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            RealityKitView(rotationSpeed: $rotationSpeed)
                .ignoresSafeArea()
            
            Button("Toggle Rotation") {
                toggleSpeed()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.bottom, 32)
        }
    }
    
    private func toggleSpeed() {
        guard let index = speeds.firstIndex(of: rotationSpeed) else {
            rotationSpeed = speeds[0]
            return
        }
        print("index: \(index ) rotationSpeed: \(rotationSpeed)")
        rotationSpeed = speeds[(index + 1) % speeds.count]
    }
}

struct RealityKitView: UIViewRepresentable {
    
    @Binding var rotationSpeed: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(
            frame: .zero,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )
        
        arView.environment.background = .color(.black)
        
        let anchor = AnchorEntity(world: .zero)
        
        let airplane = try! Entity.load(named: "Airplane")
        
        let bounds = airplane.visualBounds(relativeTo: nil)
        airplane.position = -bounds.center
        
        let maxDimension = max(bounds.extents.x,
                               bounds.extents.y,
                               bounds.extents.z)
        let scaleFactor: Float = 1.0 / maxDimension
        airplane.scale = SIMD3(repeating: scaleFactor)
        
        let sun = DirectionalLight()
        sun.light.intensity = 3_000
        sun.orientation = simd_quatf(
            angle: -.pi / 4,
            axis: SIMD3<Float>(1, 0, 0)
        )
        
        let fill = PointLight()
        fill.light.intensity = 3_000
        fill.position = SIMD3<Float>(2, 2, 2)
        
        let camera = PerspectiveCamera()
        
        anchor.addChild(airplane)
        anchor.addChild(sun)
        anchor.addChild(fill)
        anchor.addChild(camera)
        arView.scene.addAnchor(anchor)
        
        context.coordinator.subscription =
        arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            
            context.coordinator.angle +=
            Float(event.deltaTime) * context.coordinator.rotationSpeed
            
            let radius: Float = 2.0
            let x = sin(context.coordinator.angle) * radius
            let z = cos(context.coordinator.angle) * radius
            
            camera.position = SIMD3<Float>(x, 0, z)
            camera.look(
                at: .zero,
                from: camera.position,
                relativeTo: nil
            )
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.rotationSpeed = rotationSpeed
    }
    
    final class Coordinator {
        var angle: Float = 0
        var rotationSpeed: Float = 0.0
        var subscription: Cancellable?
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
