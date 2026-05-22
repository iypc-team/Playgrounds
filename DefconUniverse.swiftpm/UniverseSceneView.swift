// UniverseSceneView.swift
// Updated: Removed rotation, added real-time MotionManager camera orientation

// UniverseSceneView.swift
//

import SwiftUI
import SceneKit

struct UniverseSceneView: UIViewRepresentable {
    
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
        
        // Start streaming device motion into the camera node
        if let cameraNode = scene.rootNode.childNode(
            withName: "cameraNode", recursively: false
        ) {
            context.coordinator.startMotionUpdates(for: cameraNode)
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    // MARK: - Scene Construction
    
    private func buildScene() -> SCNScene {
        let scene = SCNScene()
        
        // ── Cubemap Skybox ─────────────────────────────────────────
        // 6 square images exported from Galaxy.jpg via equirectangular
        // to cubemap conversion. Each face should be equal in pixel size
        // (e.g. 1024×1024 or 2048×2048).
        // Face naming convention:
        //   Galaxy_px = +X (right)
        //   Galaxy_nx = -X (left)
        //   Galaxy_py = +Y (up)
        //   Galaxy_ny = -Y (down)
        //   Galaxy_pz = +Z (front)
        //   Galaxy_nz = -Z (back)
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
        
        // ── Camera ─────────────────────────────────────────────────
        let camera = SCNCamera()
        // Skybox renders at infinite distance — zFar only needs to cover
        // scene geometry, not the background.
        camera.zNear       = 0.1
        camera.zFar        = 1000
        camera.fieldOfView = 100
        
        let cameraNode = SCNNode()
        cameraNode.name     = "cameraNode"
        cameraNode.camera   = camera
        cameraNode.position = SCNVector3Zero
        
        scene.rootNode.addChildNode(cameraNode)
        return scene
    }
}

// MARK: - Coordinator

extension UniverseSceneView {
    
    class Coordinator {
        private let motionManager = MotionManager()
        private var motionTask: Task<Void, Never>?
        
        /// Begins the attitude stream and applies each quaternion to the camera node.
        func startMotionUpdates(for cameraNode: SCNNode) {
            motionTask = Task {
                do {
                    for try await attitude in await motionManager.makeAttitudeStream() {
                        let q = attitude.quaternion
                        await MainActor.run {
                            cameraNode.orientation = SCNQuaternion(
                                Float(q.x),
                                Float(q.y),
                                Float(q.z),
                                Float(q.w)
                            )
                        }
                    }
                } catch MotionError.unavailable {
                    // Device motion not available (e.g. Simulator) — camera stays fixed
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
