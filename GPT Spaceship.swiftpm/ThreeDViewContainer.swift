// 
// 

import SwiftUI
import RealityKit

struct ThreeDViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel = AirplaneViewModel()
    
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        
        // 🚫 Disable AR
        view.environment.sceneUnderstanding.options = []
        
        // 🟦 Just a 3D scene — no tracking, no camera passthrough
        view.session.pause()
        
        setupCamera(view: view)
        setupLighting(view: view)
        
        if let model = viewModel.modelEntity {
            add(model, to: view)
        }
        
        return view
    }
    
    func updateUIView(_ view: ARView, context: Context) {
        // Add model once it loads
        if let model = viewModel.modelEntity,
           model.parent == nil {
            add(model, to: view)
        }
    }
    
    private func add(_ model: ModelEntity, to view: ARView) {
        let anchor = AnchorEntity()
        anchor.addChild(model)
        
        // Center the model nicely
        model.setPosition([0, 0, 0], relativeTo: anchor)
        
        // Unified scale if your model is huge
        model.scale = SIMD3(repeating: 0.01)
        
        view.scene.anchors.append(anchor)
        
        // Orbit / pan / zoom gestures
        view.installGestures(.all, for: model)
    }
    
    // MARK: - Camera
    private func setupCamera(view: ARView) {
        let camera = PerspectiveCamera()
        camera.transform.translation = [0, 0, 2] // pull camera back
        let cameraAnchor = AnchorEntity()
        cameraAnchor.addChild(camera)
        view.scene.addAnchor(cameraAnchor)
    }
    
    // MARK: - Lighting
    private func setupLighting(view: ARView) {
        // Directional (sun)
        let directional = DirectionalLight()
        directional.light.intensity = 150_000
//        directional.light.temperature = 6500
        directional.shadow = DirectionalLightComponent.Shadow(maximumDistance: 5)
        
        let lightAnchor = AnchorEntity()
        lightAnchor.addChild(directional)
        view.scene.addAnchor(lightAnchor)
        
        // Optional: environment lighting
        view.environment.lighting.intensityExponent = 1.0
    }
}

