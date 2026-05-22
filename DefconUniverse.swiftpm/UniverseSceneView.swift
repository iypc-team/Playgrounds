// UniverseSceneView.swift
// Updated: Accepts isPaused binding to pause/resume fighterNode motion updates

import SwiftUI
import SceneKit

struct UniverseSceneView: UIViewRepresentable {
    @Binding var isPaused: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = buildScene()
        scnView.scene                      = scene
        scnView.allowsCameraControl        = false
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor            = .black
        scnView.antialiasingMode           = .multisampling4X
        
        // Stream device motion into fighterNode orientation
        if let fighterNode = scene.rootNode.childNode(
            withName: "fighterNode", recursively: false
        ) {
            context.coordinator.startMotionUpdates(for: fighterNode)
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Pause or resume motion updates based on binding
        context.coordinator.isPaused = isPaused
    }
    
    // MARK: - Scene Construction
    
    private func buildScene() -> SCNScene {
        let scene = SCNScene()
        
        // ── Cubemap Skybox ─────────────────────────────────────────
        let faceNames = [
            "Galaxy_px", "Galaxy_nx",
            "Galaxy_py", "Galaxy_ny",
            "Galaxy_pz", "Galaxy_nz"
        ]
        let faces = faceNames.map { name -> UIImage in
            let image = UIImage(named: name)
            assert(image != nil, "⚠️ Cubemap face '\(name)' is missing from Assets.xcassets.")
            return image ?? UIImage()
        }
        scene.background.contents = faces
        scene.background.intensity = 1.0
        
        // ── Fighter Scene ──────────────────────────────────────────
        let fighterNode: SCNNode
        if let fighterScene = SCNScene(named: "fighter.scn") {
            fighterNode = fighterScene.rootNode
        } else {
            assertionFailure("⚠️ fighter.scn not found in Resources.")
            fighterNode = SCNNode()
        }
        fighterNode.name     = "fighterNode"
        fighterNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(fighterNode)
        
        // ── Camera ─────────────────────────────────────────────────
        let camera = SCNCamera()
        camera.zNear       = 0.1
        camera.zFar        = 1000
        camera.fieldOfView = 100
        
        let cameraNode = SCNNode()
        cameraNode.name     = "cameraNode"
        cameraNode.camera   = camera
        // Offset behind and slightly above the fighter in local space
        cameraNode.position = SCNVector3(x: 0, y: -20, z: 5)
        
        // Lock the camera's gaze onto fighterNode at all times
        let lookAt = SCNLookAtConstraint(target: fighterNode)
        lookAt.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAt]
        
        // cameraNode is a child of fighterNode
        fighterNode.addChildNode(cameraNode)
        
        return scene
    }
}

// MARK: - Coordinator

extension UniverseSceneView {
    
    class Coordinator {
        private let motionManager = MotionManager()
        private var motionTask: Task<Void, Never>?
        var isPaused: Bool = false
        
        /// Begins the attitude stream and applies each quaternion to fighterNode.
        func startMotionUpdates(for fighterNode: SCNNode) {
            motionTask = Task {
                do {
                    for try await attitude in await motionManager.makeAttitudeStream() {
                        guard !isPaused else { continue }
                        let q = attitude.quaternion
                        await MainActor.run {
                            fighterNode.orientation = SCNQuaternion(
                                Float(q.x),
                                Float(q.y),
                                Float(q.z),
                                Float(q.w)
                            )
                        }
                    }
                } catch MotionError.unavailable {
                    print("MotionManager: device motion unavailable.")
                } catch {
                    print("MotionManager error: \(error)")
                }
            }
        }
        
        deinit {
            motionTask?.cancel()
        }
    }
}
