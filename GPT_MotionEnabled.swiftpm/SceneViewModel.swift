//
// SceneViewModel.swift
// Safe combatScene handling, no implicitly unwrapped optionals, fallback demo content when model missing,
// and robust motion stream consumption.
//

import SwiftUI
import SceneKit
import QuartzCore

@MainActor
final class SceneViewModel: ObservableObject {
    
    @Published private(set) var combatScene: SCNScene
    
    @Published private(set) var orientationState =
    OrientationState.neutral
    
    @Published var selectedShip: ShipType = .fighter
    
    @Published var shieldsEnabled = false {
        didSet {
            updateShields()
        }
    }
    
    @Published private(set) var isMotionActive = false
    
    private let motionManager = MotionManager()
    
    private let sceneController = SceneController()
    
    private var motionTask: Task<Void, Never>?
    
    private var lastUIUpdate = CACurrentMediaTime()
    
    init() {
        
        combatScene = sceneController.scene
        
        sceneController.loadShip(.fighter)
    }
    
    deinit {
        motionTask?.cancel()
    }
    
    func changeShip(to ship: ShipType) {
        
        let wasRunning = isMotionActive
        
        stopMotion()
        
        sceneController.loadShip(ship)
        
        selectedShip = ship
        
        if wasRunning {
            startMotion()
        }
    }
    
    func startMotion() {
        
        guard motionTask == nil else { return }
        
        isMotionActive = true
        
        motionTask = Task {
            
            do {
                
                let stream =
                await motionManager.makeAttitudeStream()
                
                for try await attitude in stream {
                    
                    updateOrientation(attitude)
                }
                
            } catch {
                print("motion.error")
            }
        }
    }
    
    func stopMotion() {
        
        motionTask?.cancel()
        
        motionTask = nil
        
        isMotionActive = false
        
        Task {
            await motionManager.stopUpdates()
        }
        
        resetOrientation()
    }
    
    private func updateOrientation(
        _ attitude: AttitudeQuaternion
    ) {
        
        guard let shipNode = sceneController.shipNode else {
            return
        }
        
        let x = attitude.quaternion.x
        let y = attitude.quaternion.y
        let z = attitude.quaternion.z
        let w = attitude.quaternion.w
        
        let magnitude =
        sqrt(x * x + y * y + z * z + w * w)
        
        let nx = magnitude > 0 ? x / magnitude : x
        let ny = magnitude > 0 ? y / magnitude : y
        let nz = magnitude > 0 ? z / magnitude : z
        let nw = magnitude > 0 ? w / magnitude : w
        
        let orientation =
        SCNVector4(nx, ny, nz, nw)
        
        shipNode.orientation = orientation
        
        let now = CACurrentMediaTime()
        
        if now - lastUIUpdate > 0.05 {
            
            orientationState = OrientationState(
                orientation: orientation,
                roll: attitude.roll,
                pitch: attitude.pitch,
                yaw: attitude.yaw
            )
            
            lastUIUpdate = now
        }
    }
    
    func resetOrientation() {
        
        sceneController.shipNode?.orientation =
        OrientationState.neutral.orientation
        
        orientationState = .neutral
    }
    
    private func updateShields() {
        
        guard let shields = sceneController.shieldsNode else {
            return
        }
        
        let targetOpacity: CGFloat =
        shieldsEnabled ? 1.0 : 0.0
        
        shields.runAction(
            SCNAction.fadeOpacity(
                to: targetOpacity,
                duration: 0.2
            )
        )
    }
}

