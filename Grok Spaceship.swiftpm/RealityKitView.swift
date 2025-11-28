// 
// value of type 'MotionProvider' has no member 'cancelStreaming'
// quaternion 


import SwiftUI
import RealityKit
    
struct RealityKitView: UIViewRepresentable {
    typealias RKV = RealityKitView
    
    static var rotationSpeed: Float = 0  // Angular speed in radians per second
    static var rotationAxis: SIMD3<Float> = SIMD3<Float>(0, 1, 0)  // Default Y-axis; normalize if needed
    static var isRotating: Bool = false  // Flag to control rotation
    static var rotationTimer: Timer?  // Timer for updates
    
    static let motionProvider = MotionProvider()
    static var quaternion: simd_quatf?
    
    let modelName: String
    static var arView = ARView(frame: .zero)
    static var modelEntity:ModelEntity  = ModelEntity()    // Track cumulative rotation angle
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
    
    func startRealTimeRotation(speed: Float, axis: SIMD3<Float>) {
        RKV.rotationSpeed = speed
        RKV.rotationAxis = axis
        guard !RKV.isRotating else { return }  // Prevent multiple timers
        RKV.isRotating = true
        
        // Run on the main thread for UI updates
        DispatchQueue.main.async {
            RKV.rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in  // ~60 FPS
                Task { @MainActor in
                    // Calculate incremental rotation based on speed and time delta
                    let deltaAngle = RKV.rotationSpeed / 60.0  // Adjust for timer interval (1/60 second)
                    let deltaQuat = simd_quatf(angle: deltaAngle, axis: RKV.rotationAxis)
                    RKV.modelEntity.transform.rotation *= deltaQuat
                    RKV.arView.setNeedsDisplay()  // Force refresh if needed
                }
            }
        }
    }
    
    func stopRealTimeRotation() {
        RKV.isRotating = false
        RKV.rotationTimer?.invalidate()
        RKV.rotationTimer = nil
    }
    
    func startStreamingRotation() {
        Task {
            do {
                for try await quaternion in RKV.motionProvider.quaternionStream() {
                    Task { @MainActor in
                        RKV.modelEntity.transform.rotation = quaternion
                        print("quaternion: \(quaternion)")
                        
                        RKV.arView.setNeedsDisplay()
                    }
                }
            } catch {
                print("Error streaming quaternion: \(error.localizedDescription)")
            }
        }
    }
    
//    func stopStreamingRotation() {
//        // Stop the quaternion stream, if the MotionProvider class supports stopping or canceling.
//        RKV.motionProvider.cancelStreaming()
//        print("Rotation streaming has been stopped.")
//    }
    
    // Cumulative rotation function, limited to 360° (2π radians)
    func cumulativeRotateModel(by angle: Float) {
        print("Cumulative rotate by \(angle) radians")
        // Accumulate the angle, but limit to 360° by wrapping around
        RKV.cumulativeRotationAngle = (RKV.cumulativeRotationAngle + angle).truncatingRemainder(dividingBy: 2 * .pi) // cumulative rotation to the model
        RKV.modelEntity.transform.rotation = simd_quatf(angle: RKV.cumulativeRotationAngle, axis: [0, 1, 0])
        
        // Force a UI refresh if needed 
        // RealityKit  usually handles this automatically
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
        light.light.intensity = 5000 // Lower intensity
        light.light.color = .white
        light.shadow = nil     // No shadow (more ambient feeling)
        lightAnchor.addChild(light)
        arView.scene.addAnchor(lightAnchor)
        
        // Optionally set the environment color to a light gray
//        arView.environment.background = .color(.init(white: 0.8, alpha: 1.0))
    }
    
    private func addLighting(to arView: ARView) {
        print("private func addLighting")
        let light = DirectionalLight()
        light.light.intensity = 5000
        light.light.color = .white
        let lightAnchor = AnchorEntity(world: SIMD3<Float>(0, 1, 0))
        lightAnchor.addChild(light)
        arView.scene.addAnchor(lightAnchor)
    }
}
