// SceneViewModel.swift
// Fixes applied:
//   #1 — Removed redundant stopUpdates() Task; onTermination handles CMMotionManager cleanup.
//   #2 — Removed redundant `selectedShip = ship` assignment inside changeShip(to:).
//   #3 — Motion error handling now resets isMotionActive/motionTask to unblock the UI.
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
    
    // Fix #2: Removed redundant `selectedShip = ship`.
    // The Picker binding already sets selectedShip before onChange calls this.
    func changeShip(to ship: ShipType) {
        
        let wasRunning = isMotionActive
        
        stopMotion()
        
        sceneController.loadShip(ship)
        
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
                
                // Fix #3: Reset state on error so the UI is not left stuck.
                // e.g. MotionError.unavailable fires on Simulator — without this
                // fix isMotionActive stays true and Start button stays disabled.
                isMotionActive = false
                motionTask = nil
                print("Motion error: \(error)")
            }
        }
    }
    
    // Fix #1: Removed the redundant `Task { await motionManager.stopUpdates() }`.
    // Cancelling motionTask triggers onTermination in MotionManager.makeAttitudeStream(),
    // which already calls stopDeviceMotionUpdates() — calling it again was redundant.
    func stopMotion() {
        
        motionTask?.cancel()
        motionTask = nil
        isMotionActive = false
        
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
