//  MetalParticleView.swift
//  

import SwiftUI
import MetalKit
import UIKit

public struct MetalParticleView: UIViewRepresentable {
    @Binding public var isRunning: Bool
    public var maxParticles: Int = 8000
    
    public init(isRunning: Binding<Bool>, maxParticles: Int = 8000) {
        self._isRunning = isRunning
        self.maxParticles = maxParticles
    }
    
    public func makeCoordinator() -> Coordinator { Coordinator() }
    
    public func makeUIView(context: Context) -> MTKView {
        let mtk = MTKView(frame: .zero)
        mtk.enableSetNeedsDisplay = false
        mtk.isPaused = false
        mtk.preferredFramesPerSecond = 60
        mtk.clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        context.coordinator.setup(mtkView: mtk, maxParticles: maxParticles)
        return mtk
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.isPaused = !isRunning
    }
    
    public func dismantleUIView(_ uiView: MTKView, coordinator: Coordinator) {
        uiView.isPaused = true
        uiView.delegate = nil
    }
    
    public class Coordinator {
        var renderer: MetalParticleRenderer?
        
        func setup(mtkView: MTKView, maxParticles: Int) {
            if renderer == nil {
                renderer = MetalParticleRenderer(mtkView: mtkView, maxParticles: maxParticles)
            } else {
                mtkView.delegate = renderer
            }
        }
    }
}
