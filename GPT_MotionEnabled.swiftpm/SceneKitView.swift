// SceneKitView.swift
// 

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    
    let scene: SCNScene
    let allowsCameraControl: Bool
    let preset: PerformancePreset
    var viewModel: SceneViewModel?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        scnView.scene = scene
        scnView.backgroundColor = .black
        scnView.autoenablesDefaultLighting = false
        scnView.isPlaying = true
        scnView.delegate = context.coordinator
        scnView.allowsCameraControl = allowsCameraControl
        
        applyQuality(to: scnView)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.allowsCameraControl = allowsCameraControl
        applyQuality(to: scnView)
    }
    
    private func applyQuality(to view: SCNView) {
        view.antialiasingMode = preset.antialiasingMode
        view.isTemporalAntialiasingEnabled = preset.temporalAntialiasing
        view.showsStatistics = preset.showsStatistics
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        weak var viewModel: SceneViewModel?
        
        init(viewModel: SceneViewModel?) {
            self.viewModel = viewModel
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // You can add custom per-frame logic here in the future
            // (e.g. smoothing, particle updates, etc.)
        }
    }
}

