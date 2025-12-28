// Updated SceneViewModel.swift (added cameraPosition as @Published, and updated functions)

import Foundation
import SceneKit

class SceneViewModel: ObservableObject {
    // Observable property to notify the view of changes
    @Published var sceneModel: SceneModel
    @Published var cameraPosition: SCNVector3
    @Published var currentRotationX: Float = 0
    @Published var isRotatingX = false
    var timerX: Timer?
    @Published var currentRotationY: Float = 0
    @Published var isRotatingY = false
    var timerY: Timer?
    @Published var currentRotationZ: Float = 0
    @Published var isRotatingZ = false
    var timerZ: Timer?
    
    init(sceneName: String) {
        let initialCameraPosition = SCNVector3(x: 0, y: 0, z: 20)
        self.cameraPosition = initialCameraPosition
        // Initialize SceneModel
        self.sceneModel = SceneModel(sceneName: sceneName, cameraPosition: initialCameraPosition)
    }
    
    // Functions to manipulate the SceneModel or interact with the view
    func updateCameraPosition(_ position: SCNVector3) {
        self.cameraPosition = position
        sceneModel.cameraNode?.position = position
    }
    
    func addLightNode(light: SCNNode) {
        sceneModel.lightNodes.append(light)
        sceneModel.scene?.rootNode.addChildNode(light)
    }
    
    func cameraPositionPlus(_ delta: SCNVector3) {
        if let currentPosition = sceneModel.cameraNode?.position {
            let newPosition = SCNVector3(
                x: currentPosition.x + delta.x,
                y: currentPosition.y + delta.y,
                z: currentPosition.z + delta.z
            )
            updateCameraPosition(newPosition)
        }
    }
    
    func cameraPositionMinus(_ delta: SCNVector3) {
        if let currentPosition = sceneModel.cameraNode?.position {
            let newPosition = SCNVector3(
                x: currentPosition.x + delta.x,
                y: currentPosition.y + delta.y,
                z: currentPosition.z + delta.z
            )
            updateCameraPosition(newPosition)
        }
    }
    
    func rotateModelOnXAxis() {
        if !isRotatingX {
            isRotatingX = true
            timerX = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentRotationX += 22.5
                if self.currentRotationX >= 360 {
                    self.currentRotationX = 360
                    self.timerX?.invalidate()
                    self.isRotatingX = false
                }
            }
        }
    }
    
    func rotateModelOnYAxis() {
        if !isRotatingY {
            isRotatingY = true
            timerY = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentRotationY += 22.5
                if self.currentRotationY >= 360 {
                    self.currentRotationY = 360
                    self.timerY?.invalidate()
                    self.isRotatingY = false
                }
            }
        }
    }
    
    func rotateModelOnZAxis() {
        if !isRotatingZ {
            isRotatingZ = true
            timerZ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentRotationZ += 22.5
                if self.currentRotationZ >= 360 {
                    self.currentRotationZ = 360
                    self.timerZ?.invalidate()
                    self.isRotatingZ = false
                }
            }
        }
    }
}
