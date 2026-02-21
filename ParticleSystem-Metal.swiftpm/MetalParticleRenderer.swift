//  MetalParticleRenderer.swift
//  Updated: namespaced ComputeParams and fixed pointer binding errors
//  


import Foundation
import Metal
import MetalKit
import simd
import UIKit

// MARK: - Swift-side structs matching MSL
// Namespaced to avoid top-level ComputeParams collision with generated shader symbol
enum ShaderTypes {
    struct ComputeParams {
        var dt: Float
        var lifespan: Float
        var center: SIMD2<Float>           // unit-space center
        var emissionDirectionX: Float
        var emissionDirectionY: Float
        var spread: Float
        var speedMin: Float
        var speedMax: Float
        var sizeMin: Float
        var sizeMax: Float
        var hueMin: Float
        var hueMax: Float
        var maxParticles: UInt32
        var emitCount: UInt32
        var seedBase: UInt32
        var viewportSize: SIMD2<Float>
    }
}

struct GPUParticle {
    var pos: SIMD2<Float>
    var vel: SIMD2<Float>
    var size: Float
    var hue: Float
    var age: Float
    var alive: UInt32
}

final class MetalParticleRenderer: NSObject, MTKViewDelegate {
    // Public tuning
    var emissionRate: Double = 1400.0
    var lifespan: TimeInterval = 0.9
    var emissionDirection = CGVector(dx: 0.0, dy: -1.0)
    var spread: Double = .pi * 0.02
    var speedRange: ClosedRange<Double> = 3.0...6.0
    var sizeRange: ClosedRange<Double> = 0.8...1.6
    var hueRange: ClosedRange<Double> = 0.58...0.66
    var center: CGPoint = CGPoint(x: 0.5, y: 0.88)
    var maxParticles: Int = 8000
    
    // Metal objects
    private let device: MTLDevice
    private let queue: MTLCommandQueue
    private let library: MTLLibrary
    
    private var emitPipeline: MTLComputePipelineState!
    private var integratePipeline: MTLComputePipelineState!
    private var renderPipeline: MTLRenderPipelineState!
    
    private var particleBuffer: MTLBuffer!
    private var paramsBuffer: MTLBuffer!
    private var headBuffer: MTLBuffer!
    private var seedBuffer: MTLBuffer!
    private var glowTexture: MTLTexture!
    
    private var quadVertexBuffer: MTLBuffer!
    
    private var lastDate: TimeInterval?
    private var emissionAccumulator: Double = 0.0
    
    init?(mtkView: MTKView, maxParticles: Int = 8000) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let queue = device.makeCommandQueue()
        else { return nil }
        self.device = device
        self.queue = queue
        self.maxParticles = maxParticles
        
        guard let library = device.makeDefaultLibrary() else {
            print("Failed to load default Metal library - ensure .metal is in the target.")
            return nil
        }
        self.library = library
        
        super.init()
        
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.delegate = self
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.framebufferOnly = false
        
        do {
            try buildPipelines(mtkView: mtkView)
            allocateBuffers()
            createGlowTexture()
        } catch {
            print("Metal setup failed: \(error)")
            return nil
        }
    }
    
    private func buildPipelines(mtkView: MTKView) throws {
        guard let emitFunc = library.makeFunction(name: "emitKernel"),
              let integrateFunc = library.makeFunction(name: "integrateKernel"),
              let vertexFunc = library.makeFunction(name: "particleVertex"),
              let fragmentFunc = library.makeFunction(name: "particleFragment")
        else { throw NSError(domain: "Metal", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing shader functions"]) }
        
        emitPipeline = try device.makeComputePipelineState(function: emitFunc)
        integratePipeline = try device.makeComputePipelineState(function: integrateFunc)
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunc
        descriptor.fragmentFunction = fragmentFunc
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = .add
        descriptor.colorAttachments[0].alphaBlendOperation = .add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
        
        renderPipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        
        // Vertex quad (triangle strip 4 verts)
        let quadVerts: [SIMD2<Float>] = [
            SIMD2<Float>(-1, -1),
            SIMD2<Float>( 1, -1),
            SIMD2<Float>(-1,  1),
            SIMD2<Float>( 1,  1)
        ]
        quadVertexBuffer = device.makeBuffer(bytes: quadVerts, length: MemoryLayout<SIMD2<Float>>.stride * quadVerts.count, options: [])
    }
    
    private func allocateBuffers() {
        // Create buffers (makeBuffer returns optionals; assign to IUOs)
        particleBuffer = device.makeBuffer(length: MemoryLayout<GPUParticle>.stride * maxParticles, options: .storageModeShared)
        paramsBuffer = device.makeBuffer(length: MemoryLayout<ShaderTypes.ComputeParams>.stride, options: .storageModeShared)
        headBuffer = device.makeBuffer(length: MemoryLayout<UInt32>.stride, options: .storageModeShared)
        seedBuffer = device.makeBuffer(length: MemoryLayout<UInt32>.stride * 4096, options: .storageModeShared)
        
        // zero head (guard buffer exists then write)
        if let headBuf = headBuffer {
            let headPtr = headBuf.contents().assumingMemoryBound(to: UInt32.self)
            headPtr.pointee = 0
        }
        
        // zero particles (guard buffer exists then bind memory and initialize)
        if let pbuf = particleBuffer {
            let pptr = pbuf.contents().bindMemory(to: GPUParticle.self, capacity: maxParticles)
            for i in 0..<maxParticles {
                pptr[i].pos = SIMD2<Float>(0, 0)
                pptr[i].vel = SIMD2<Float>(0, 0)
                pptr[i].size = 0
                pptr[i].hue = 0
                pptr[i].age = 0
                pptr[i].alive = 0
            }
        }
    }
    
    private func createGlowTexture() {
        let size = 64
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: size, height: size, mipmapped: false)
        desc.usage = [.shaderRead]
        glowTexture = device.makeTexture(descriptor: desc)
        
        var pixels = [UInt8](repeating: 0, count: size * size * 4)
        for y in 0..<size {
            for x in 0..<size {
                let fx = (Float(x) + 0.5) / Float(size) * 2.0 - 1.0
                let fy = (Float(y) + 0.5) / Float(size) * 2.0 - 1.0
                let r = sqrt(fx*fx + fy*fy)
                let t = max(0, min(1, 1.0 - r))
                let alphaFloat = t * t * (3 - 2*t) // smoothstep
                let alpha = UInt8(max(0, min(255, Int(alphaFloat * 255.0))))
                let idx = (y * size + x) * 4
                pixels[idx+0] = 255
                pixels[idx+1] = 255
                pixels[idx+2] = 255
                pixels[idx+3] = alpha
            }
        }
        let region = MTLRegionMake2D(0, 0, size, size)
        glowTexture.replace(region: region, mipmapLevel: 0, withBytes: pixels, bytesPerRow: size * 4)
    }
    
    // MARK: - MTKViewDelegate
    
    func draw(in view: MTKView) {
        guard let commandBuffer = queue.makeCommandBuffer(),
              let drawable = view.currentDrawable else { return }
        
        // frame timing (clamped)
        let now = CACurrentMediaTime()
        var dt: TimeInterval = 1.0/60.0
        if let last = lastDate {
            dt = max(0.0, min(1.0/15.0, now - last))
        }
        lastDate = now
        
        // compute emissions this frame
        let toEmit = emissionRate * dt + emissionAccumulator
        var emitCount = Int(floor(toEmit))
        emissionAccumulator = toEmit - Double(emitCount)
        emitCount = max(0, min(emitCount, maxParticles))
        
        // ensure seedBuffer capacity
        if emitCount > 0 {
            // if seedBuffer is nil, create a new one
            let currentSlots = seedBuffer?.length ?? 0 / MemoryLayout<UInt32>.stride
            if emitCount > currentSlots {
                seedBuffer = device.makeBuffer(length: MemoryLayout<UInt32>.stride * emitCount, options: .storageModeShared)
            }
            guard let seedBuf = seedBuffer else { return }
            let seedPtr = seedBuf.contents().assumingMemoryBound(to: UInt32.self)
            for i in 0..<emitCount {
                seedPtr[i] = UInt32(arc4random()) ^ UInt32(i & 0xFFFFFFFF)
            }
        }
        
        // prepare params (unit-space for center; viewport in px)
        let viewSize = view.drawableSize
        var params = ShaderTypes.ComputeParams(
            dt: Float(dt),
            lifespan: Float(lifespan),
            center: SIMD2<Float>(Float(center.x), Float(center.y)),
            emissionDirectionX: Float(emissionDirection.dx),
            emissionDirectionY: Float(emissionDirection.dy),
            spread: Float(spread),
            speedMin: Float(speedRange.lowerBound),
            speedMax: Float(speedRange.upperBound),
            sizeMin: Float(sizeRange.lowerBound),
            sizeMax: Float(sizeRange.upperBound),
            hueMin: Float(hueRange.lowerBound),
            hueMax: Float(hueRange.upperBound),
            maxParticles: UInt32(maxParticles),
            emitCount: UInt32(emitCount),
            seedBase: 0,
            viewportSize: SIMD2<Float>(Float(viewSize.width), Float(viewSize.height))
        )
        
        // copy params to GPU buffer
        guard let paramsBuf = paramsBuffer else { return }
        memcpy(paramsBuf.contents(), &params, MemoryLayout<ShaderTypes.ComputeParams>.stride)
        
        // dispatch emit kernel
        if emitCount > 0 {
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            encoder.setComputePipelineState(emitPipeline)
            encoder.setBuffer(particleBuffer, offset: 0, index: 0)
            encoder.setBuffer(headBuffer, offset: 0, index: 1)
            encoder.setBuffer(seedBuffer, offset: 0, index: 2)
            encoder.setBuffer(paramsBuffer, offset: 0, index: 3)
            
            let threadsPerThreadgroup = MTLSize(width: emitPipeline.threadExecutionWidth, height: 1, depth: 1)
            let threadsPerGrid = MTLSize(width: emitCount, height: 1, depth: 1)
            encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
        
        // dispatch integrate kernel across all particles
        if let encoder = commandBuffer.makeComputeCommandEncoder() {
            encoder.setComputePipelineState(integratePipeline)
            encoder.setBuffer(particleBuffer, offset: 0, index: 0)
            encoder.setBuffer(paramsBuffer, offset: 0, index: 1)
            
            let threadsPerThreadgroup = MTLSize(width: integratePipeline.threadExecutionWidth, height: 1, depth: 1)
            let threadsPerGrid = MTLSize(width: maxParticles, height: 1, depth: 1)
            encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
        
        // render pass
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = drawable.texture
        renderPass.colorAttachments[0].loadAction = .clear
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        if let rencoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) {
            rencoder.setRenderPipelineState(renderPipeline)
            rencoder.setVertexBuffer(quadVertexBuffer, offset: 0, index: 0)
            rencoder.setVertexBuffer(particleBuffer, offset: 0, index: 1)
            rencoder.setVertexBuffer(paramsBuffer, offset: 0, index: 2)
            
            rencoder.setFragmentTexture(glowTexture, index: 0)
            rencoder.setFragmentSamplerState(defaultSampler(), index: 0)
            
            // draw triangle strip (4 verts) instanced for maxParticles
            rencoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: maxParticles)
            rencoder.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // nothing special now
    }
    
    private func defaultSampler() -> MTLSamplerState? {
        let desc = MTLSamplerDescriptor()
        desc.minFilter = .linear
        desc.magFilter = .linear
        desc.mipFilter = .notMipmapped
        desc.sAddressMode = .clampToEdge
        desc.tAddressMode = .clampToEdge
        return device.makeSamplerState(descriptor: desc)
    }
}
