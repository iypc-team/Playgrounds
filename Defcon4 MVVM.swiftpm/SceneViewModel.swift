// 
// 

import Foundation
import SceneKit

class SceneViewModel: ObservableObject {
    // Observable property to notify the view of changes
    @Published var sceneModel: SceneModel
    @Published var currentRotationX: Float = 0
    @Published var isRotatingX = false
    @Published var currentRotationY: Float = 0
    @Published var isRotatingY = false
    @Published var currentRotationZ: Float = 0
    @Published var isRotatingZ = false
    
    init(sceneName: String) {
        let initialCameraPosition = SCNVector3(x: 0, y: 0, z: 20)
        // Initialize SceneModel
        self.sceneModel = SceneModel(sceneName: sceneName, cameraPosition: initialCameraPosition)
    }
    
    func addLightNode(light: SCNNode) {
        sceneModel.lightNodes.append(light)
        sceneModel.scene?.rootNode.addChildNode(light)
    }
    
    func rotateModelOnXAxis() {
        guard !isRotatingX else { return }
        isRotatingX = true
        Task {
            while currentRotationX < 360 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                currentRotationX += 22.5
                if currentRotationX >= 360 {
                    currentRotationX = 360
                }
            }
            isRotatingX = false
        }
    }
    
    func rotateModelOnYAxis() {
        guard !isRotatingY else { return }
        isRotatingY = true
        Task {
            while currentRotationY < 360 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                currentRotationY += 22.5
                if currentRotationY >= 360 {
                    currentRotationY = 360
                }
            }
            isRotatingY = false
        }
    }
    
    func rotateModelOnZAxis() {
        guard !isRotatingZ else { return }
        isRotatingZ = true
        Task {
            while currentRotationZ < 360 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                currentRotationZ += 22.5
                if currentRotationZ >= 360 {
                    currentRotationZ = 360
                }
            }
            isRotatingZ = false
        }
    }
}

