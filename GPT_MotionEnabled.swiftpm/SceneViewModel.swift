// SceneViewModel.swift

import SwiftUI
import SceneKit
import QuartzCore

@MainActor
final class SceneViewModel: ObservableObject {
    
    @Published private(set) var combatScene: SCNScene
    @Published private(set) var orientationState = OrientationState.neutral
    @Published var selectedShip: ShipType = .fighter
    @Published var shieldsEnabled = false {
        didSet { updateShields() }
    }
    @Published private(set) var isMotionActive = false
    @Published var performancePreset: PerformancePreset = .medium
    
    private let motionManager = MotionManager()
    private let sceneController = SceneController()
    
    private var motionTask: Task<Void, Never>?
    private var lastUIUpdate = CACurrentMediaTime()
    
    init() {
        combatScene = sceneController.scene
        sceneController.loadShip(.fighter)
    }
    
    deinit { motionTask?.cancel() }
    
    func changeShip(to ship: ShipType) {
        let wasRunning = isMotionActive
        stopMotion()
        sceneController.loadShip(ship)
        if wasRunning { startMotion() }
    }
    
    func startMotion() {
        guard motionTask == nil else { return }
        isMotionActive = true
        
        motionTask = Task {
            do {
                let stream = await motionManager.makeAttitudeStream(
                    updateInterval: performancePreset.motionUpdateInterval,
                    throttleInterval: 1.0 / 180.0
                )
                
                for try await attitude in stream {
                    await updateOrientation(attitude)
                }
            } catch {
                isMotionActive = false
                motionTask = nil
            }
        }
    }
    
    func stopMotion() {
        motionTask?.cancel()
        motionTask = nil
        isMotionActive = false
        resetOrientation()
    }
    
    func resetOrientation() {
        // Core fix: Reset the actual ship node
        guard let shipNode = sceneController.shipNode else { return }
        
        // Smooth reset using SCNTransaction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.4
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        shipNode.orientation = SCNVector4(0, 0, 0, 1)   // Identity quaternion
        SCNTransaction.commit()
        
        // Reset UI state
        orientationState = .neutral
        lastUIUpdate = CACurrentMediaTime()
    }
    
    private func updateOrientation(_ attitude: AttitudeQuaternion) async {
        guard let shipNode = sceneController.shipNode else { return }
        
        let q = attitude.quaternion
        let magnitude = sqrt(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w)
        let norm = magnitude > 0.001 ? 
        SCNVector4(q.x/magnitude, q.y/magnitude, q.z/magnitude, q.w/magnitude) : 
        SCNVector4(0, 0, 0, 1)
        
        shipNode.orientation = norm
        
        let now = CACurrentMediaTime()
        if now - lastUIUpdate > performancePreset.uiThrottleInterval {
            orientationState = OrientationState(
                orientation: norm,
                roll: attitude.roll,
                pitch: attitude.pitch,
                yaw: attitude.yaw
            )
            lastUIUpdate = now
        }
    }
    
    private func updateShields() {
        sceneController.shieldsNode?.isHidden = !shieldsEnabled
    }
}
