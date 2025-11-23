// 
// RealityKitView

import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    let modelName: String
    @Binding var rotation: Float
    
    func makeUIView(context: Context) -> ARView {
        print("\nfunc makeUIView")
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR  // Disable AR tracking for non-AR 3D display
        loadModel(into: arView)
        addLighting(to: arView)
        addRotationGesture(to: arView, context: context)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        print("func updateUIView")
        if let modelEntity = uiView.scene.findEntity(named: modelName) as? ModelEntity {
            modelEntity.transform.rotation = simd_quatf(angle: rotation, axis: [0,1,0])
        }
    }
    
    private func loadModel(into arView: ARView) {
        print("private func loadModel")
        let anchor = AnchorEntity(world: .zero)
        if let modelEntity = try? ModelEntity.load(named: modelName) {
            modelEntity.name = modelName
            modelEntity.transform.scale = SIMD3<Float>(5.0, 5.0, 5.0) // Scale the model
            print("\tmodelEntity.scale: \(modelEntity.scale)")
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
        }
    }
    
    
    private func addLighting(to arView: ARView) {
        print("private func addLighting")
        let light = DirectionalLight()
        light.light.intensity = 10000
        light.light.color = .lightGray
        let lightAnchor = AnchorEntity(world: SIMD3<Float>(0, 1, 0))
        lightAnchor.addChild(light)
        arView.scene.addAnchor(lightAnchor)
    }
    
    private func addRotationGesture(to arView: ARView, context: Context) {
        print("private func addRotationGesture")
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
    }
    
    func makeCoordinator() -> Coordinator {
        print("func makeCoordinator")
        return Coordinator(rotation: $rotation)
    }
    
    class Coordinator: NSObject {
        var rotation: Binding<Float>
        init(rotation: Binding<Float>) {
            self.rotation = rotation
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            rotation.wrappedValue += Float(gesture.rotation)
            gesture.rotation = 0
        }
    }
}

