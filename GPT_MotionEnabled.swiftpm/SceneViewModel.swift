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
    
    // Changed default from .medium to .low
    @Published var performancePreset: PerformancePreset = .low
    
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
    
    // MARK: - Ship Management
    
    func changeShip(to ship: ShipType) {
        let wasRunning = isMotionActive
        stopMotion()
        sceneController.loadShip(ship)
        if wasRunning {
            startMotion()
        }
    }
    
    // MARK: - Motion Control
    
    func startMotion() {
        guard motionTask == nil else { return }
        
        isMotionActive = true
        
        motionTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let stream: AsyncThrowingStream<MotionData, Error> = await motionManager.makeMotionStream(
                    updateInterval: performancePreset.motionUpdateInterval,
                    relative: true
                )
                
                for try await motionData in stream {
                    try Task.checkCancellation()
                    
                    await self.updateOrientation(motionData.attitude)
                }
            } catch {
                if error is CancellationError {
                    print("✅ Motion task cancelled gracefully")
                } else {
                    print("❌ Motion error: \(error)")
                }
                
                await MainActor.run {
                    self.isMotionActive = false
                    self.motionTask = nil
                }
            }
        }
    }
    
    func stopMotion() {
        motionTask?.cancel()
        motionTask = nil
        isMotionActive = false
        resetOrientation()
    }
    
    // MARK: - Orientation
    
    func resetOrientation() {
        guard let shipNode = sceneController.shipNode else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.4
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        shipNode.orientation = SCNVector4(0, 0, 0, 1)
        SCNTransaction.commit()
        
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
    
    // MARK: - Shields
    
    private func updateShields() {
        sceneController.shieldsNode?.isHidden = !shieldsEnabled
    }
}
