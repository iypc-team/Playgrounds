// 
// RealityKitView
// modelEntity


import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    let modelName: String
    static var arView = ARView(frame: .zero)
    static var modelEntity:ModelEntity  = ModelEntity()
    // Static variable to track cumulative rotation angle
    static var cumulativeRotationAngle: Float = 0
    
    func makeUIView(context: Context) -> ARView {
        print("\nfunc makeUIView")
        RealityKitView.arView.cameraMode = .nonAR  // Disable AR tracking for non-AR 3D display
        loadModel(into: RealityKitView.arView)
        addLighting(to: RealityKitView.arView)
        addAmbientLikeLighting(to: RealityKitView.arView)  // This is the new ambient light
        return RealityKitView.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        print("func updateUIView")
        if RealityKitView.modelEntity == uiView.scene.findEntity(named: modelName) as? ModelEntity {
            
        }
    }
    
    private func loadModel(into arView: ARView) {
        print("private func loadModel")
        let anchor = AnchorEntity(world: .zero)
        if let modelEntity = try? ModelEntity.load(named: modelName) {
            modelEntity.name = modelName
            modelEntity.transform.scale = SIMD3<Float>(4.0, 4.0, 4.0) // Scale the model
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
        }
    }
    
    // Cumulative rotation function, limited to 360° (2π radians)
    func cumulativeRotateModel(by angle: Float) {
        print("Cumulative rotate by \(angle) radians")
        // Accumulate the angle, but limit to 360° by wrapping around
        RealityKitView.cumulativeRotationAngle = (RealityKitView.cumulativeRotationAngle + angle).truncatingRemainder(dividingBy: 2 * .pi)
        // Apply the cumulative rotation to the model
        RealityKitView.modelEntity.transform.rotation = simd_quatf(angle: RealityKitView.cumulativeRotationAngle, axis: [0, 1, 0])
        // Force a UI refresh if needed (though RealityKit usually handles this automatically)
        RealityKitView.arView.setNeedsDisplay()
    }
    
    func rotateModel() {
        print("func rotateModel()")
        // Rotate the model by 45 degrees around the Y-axis
        RealityKitView.modelEntity.transform.rotation *= simd_quatf(angle: .pi / 4, axis: [0, 1, 0])
        
        RealityKitView.arView.setNeedsDisplay()
    }
    
    private func addAmbientLikeLighting(to arView: ARView) {
        // Add a soft directional light as ambient substitute
        let lightAnchor = AnchorEntity(world: .zero)
        let light = DirectionalLight()
        light.light.intensity = 700   // Lower intensity
        light.light.color = .white
        light.shadow = nil            // No shadow (more ambient feeling)
        lightAnchor.addChild(light)
        arView.scene.addAnchor(lightAnchor)
        
        // Optionally set the environment color to a light gray
        arView.environment.background = .color(.init(white: 0.8, alpha: 1.0))
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
}
