// SceneViewModel.swift
// Fully updated to work with the new MotionManager

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
    @Published var performancePreset: PerformancePreset = .low
    @Published private(set) var magneticAccuracy: CMMagneticFieldCalibrationAccuracy = .uncalibrated
    @Published private(set) var lastError: String?
    
    private let motionManager: MotionManager   // Now uses public init
    private let sceneController = SceneController()
    
    private var motionTask: Task<Void, Never>?
    private var lastUIUpdate = CACurrentMediaTime()
    
    init() {
        self.motionManager = MotionManager()   // Fixed initializer access
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
        if wasRunning {
            startMotion()
        }
    }
    
    func startMotion() {
        guard motionTask == nil else { return }
        
        isMotionActive = true
        lastError = nil
        
        motionTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.motionManager.calibrate()
                
                await self.motionManager.startDeviceMotionUpdates(
                    interval: self.performancePreset.motionUpdateInterval
                ) { [weak self] data in
                    guard let self else { return }
                    Task { @MainActor in
                        await self.handleMotionData(data)
                    }
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isMotionActive = false
                    print("Motion error: \(error)")
                }
            }
        }
    }
    
    func stopMotion() {
        motionTask?.cancel()
        motionTask = nil
        motionManager.stop()
        isMotionActive = false
        resetOrientation()
        magneticAccuracy = .uncalibrated
    }
    
    private func handleMotionData(_ data: MotionData) async {
        if let accuracy = data.magneticField?.accuracy {
            self.magneticAccuracy = accuracy
        }
        await updateOrientation(data.attitude)
    }
    
    private func updateOrientation(_ attitude: AttitudeQuaternion) async {
        guard let shipNode = sceneController.shipNode else { return }
        
        let q = attitude.quaternion
        let mag = sqrt(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w)
        let normalized = mag > 0.001 ?
        SCNVector4(q.x/mag, q.y/mag, q.z/mag, q.w/mag) : SCNVector4(0, 0, 0, 1)
        
        shipNode.orientation = normalized
        
        let now = CACurrentMediaTime()
        if now - lastUIUpdate > performancePreset.uiThrottleInterval {
            orientationState = OrientationState(
                orientation: normalized,
                roll: attitude.roll,
                pitch: attitude.pitch,
                yaw: attitude.yaw
            )
            lastUIUpdate = now
        }
    }
    
    func resetOrientation() {
        guard let shipNode = sceneController.shipNode else { return }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.4
        shipNode.orientation = SCNVector4(0, 0, 0, 1)
        SCNTransaction.commit()
        orientationState = .neutral
    }
    
    private func updateShields() {
        sceneController.shieldsNode?.isHidden = !shieldsEnabled
    }
}
