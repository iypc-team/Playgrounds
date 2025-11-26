// 
// RealityKitView
// quaternion 


import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    typealias RKV = RealityKitView
    static let motionProvider = MotionProvider()
    static var quaternion: simd_quatf?
    
    let modelName: String
    static var arView = ARView(frame: .zero)
    static var modelEntity:ModelEntity  = ModelEntity()
    // Static variable to track cumulative rotation angle
    static var cumulativeRotationAngle: Float = 0
    
    func makeUIView(context: Context) -> ARView {
        print("\nfunc makeUIView")
        
        _ = RKV.arView
        startStreamingRotation()
        
        RKV.arView.cameraMode = .nonAR  // Disable AR tracking for non-AR 3D display
        loadModel(into: RKV.arView)
        addLighting(to: RKV.arView)
        addAmbientLikeLighting(to: RKV.arView)  // This is the new ambient light
        
        return RKV.arView
    }
    
    @MainActor
    func updateUIView(_ uiView: ARView, context: Context) {
        print("func updateUIView")
        if RKV.modelEntity == uiView.scene.findEntity(named: modelName) as? ModelEntity {
            RKV.modelEntity.transform.rotation *= RKV.quaternion!
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
    
    func startStreamingRotation() {
        Task {
            do {
                for try await quaternion in RKV.motionProvider.quaternionStream() {
                    Task { @MainActor in
                        RKV.modelEntity.transform.rotation = quaternion
                        RKV.arView.setNeedsDisplay()
                    }
                }
            } catch {
                print("Error streaming quaternion: \(error.localizedDescription)")
            }
        }
    }
    
    // Cumulative rotation function, limited to 360° (2π radians)
    func cumulativeRotateModel(by angle: Float) {
        print("Cumulative rotate by \(angle) radians")
        // Accumulate the angle, but limit to 360° by wrapping around
        RKV.cumulativeRotationAngle = (RKV.cumulativeRotationAngle + angle).truncatingRemainder(dividingBy: 2 * .pi)
        // Apply the cumulative rotation to the model
        RKV.modelEntity.transform.rotation = simd_quatf(angle: RKV.cumulativeRotationAngle, axis: [0, 1, 0])
        // Force a UI refresh if needed (though RealityKit usually handles this automatically)
        RKV.arView.setNeedsDisplay()
    }
    
    func rotateModel() {
        print("func rotateModel()")
        // Rotate the model by 45 degrees around the Y-axis
        RKV.modelEntity.transform.rotation *= simd_quatf(angle: .pi / 4, axis: [0, 1, 0])
        print("rotation: \(RKV.modelEntity.transform.rotation)")
        RKV.arView.setNeedsDisplay()
    }
    
    private func addAmbientLikeLighting(to arView: ARView) {
        // Add a soft directional light as ambient substitute
        let lightAnchor = AnchorEntity(world: .zero)
        let light = DirectionalLight()
        light.light.intensity = 700   // Lower intensity
        light.light.color = .white
        light.shadow = nil     // No shadow (more ambient feeling)
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
