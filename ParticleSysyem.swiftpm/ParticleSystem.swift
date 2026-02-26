// ParticleSystem.swift
// Updated: focused, pencil-shaped exhaust (sharpened pencil)
// Added: globalScale (scales emission rate, size, speed, and nozzle radius)
// Tweaks: reduced default particle size & density for a smaller stream,
// clamp large dt after long pauses, avoid advancing lastUpdateDate when stopped,
// expose simple active/empty checks.
// Note: global Swift.max / Swift.min qualified to avoid name ambiguity.

import SwiftUI
import Foundation
import Darwin

struct Particle {
    // unit-space coordinates (0..1) relative to drawing container
    var x: Double
    var y: Double
    
    // velocity in unit-space per second
    var vx: Double
    var vy: Double
    
    // initial size in points (used by drawing code)
    let size: Double
    
    // hue (0..1) for color mapping
    let hue: Double
    
    // creation timestamp
    let creationDate: TimeInterval
}

final class ParticleSystem: Sequence {
    // Particles
    private(set) var particles: [Particle] = []
    
    // Where particles originate (unit coordinates) - nozzle near bottom center
    var center: UnitPoint = .init(x: 0.5, y: 0.88)
    
    // How long a particle lives (seconds)
    var lifespan: TimeInterval = 0.8     // slightly shorter lifespan to reduce visual spread
    
    // Emission properties tuned for a tight focused beam
    // Public-facing "base" parameters; globalScale multiplies these at runtime.
    var emissionRate: Double = 700                    // particles per second (base)
    var emissionDirection: CGVector = CGVector(dx: 0.0, dy: -1.0) // up (negative y)
    var spread: Double = .pi * 0.02                    // very narrow cone
    var speedRange: ClosedRange<Double> = 3.0...6.0    // base speeds (unit-space / s)
    var sizeRange: ClosedRange<Double> = 0.5...1.1     // base core sizes (points)
    var hueRange: ClosedRange<Double> = 0.58...0.66    // bluish-white beam
    var maxParticles: Int = 8000                      // safety cap (base)
    
    // Emission geometry & motion tuning (base)
    var radialEmissionRadius: Double = 0.003 // nozzle radius in unit-space (base)
    var axisAttraction: Double = 6.0         // pulls particles toward axis (keeps beam tight)
    var lateralBoost: Double = 0.0           // no lateral spreading
    var buoyancy: Double = 0.0               // disable upward billow
    
    // Global scale: multiplies emission rate, particle size, speeds and nozzle radius.
    // Use values <= 1.0 to shrink the stream (e.g. 0.5 halves size & emission); 1.0 is default.
    var globalScale: Double = 1.0 / 4 {
        didSet {
            // sanitize
            if globalScale.isNaN || globalScale < 0.0 { globalScale = 0.0 }
        }
    }
    
    // internal bookkeeping
    private var lastUpdateDate: TimeInterval?
    private var emissionAccumulator: Double = 0
    
    // optional image kept for compatibility if you choose to use sprites instead of shapes
    //    let image = Image("spark")
    let image = Image("star")
    
    // Public convenience checks
    var isEmpty: Bool { particles.isEmpty }
    // consider emitter active if either base emissionRate > 0 and scale > 0, or particles exist
    var isActive: Bool { (emissionRate * globalScale) > 0 || !particles.isEmpty }
    
    /// Call once per frame with timeline.date.timeIntervalSinceReferenceDate
    func update(date: TimeInterval) {
        // If the emitter is fully stopped and there are no particles, do nothing.
        // Also avoid advancing lastUpdateDate in that paused state so we won't
        // accumulate a huge dt when resuming.
        if (emissionRate * globalScale) == 0 && particles.isEmpty {
            lastUpdateDate = nil
            return
        }
        
        // initialize lastUpdateDate on first call (or after a pause)
        guard let last = lastUpdateDate else {
            lastUpdateDate = date
            return
        }
        
        // compute dt and clamp to avoid huge jumps after backgrounding or long pauses
        let rawDt = Swift.max(0, date - last)
        let maxDt: TimeInterval = 1.0 / 15.0   // clamp to ~66ms to keep simulation stable
        let dt = Swift.min(rawDt, maxDt)
        lastUpdateDate = date
        
        // apply scaling to derived parameters
        let effectiveEmissionRate = emissionRate * globalScale
        // scale speeds linearly (smaller globalScale -> slower, less spread)
        let effectiveSpeedRange = (speedRange.lowerBound * globalScale)...(speedRange.upperBound * globalScale)
        // scale sizes (points)
        let effectiveSizeRange = (sizeRange.lowerBound * globalScale)...(sizeRange.upperBound * globalScale)
        // scale nozzle radius in unit-space
        let effectiveRadialEmissionRadius = radialEmissionRadius * globalScale
        // compute effective max particles (at least a small positive floor)
        let effectiveMaxParticles = Swift.max(16, Int(Double(maxParticles) * Swift.max(globalScale, 0.01)))
        
        // spawn particles according to effectiveEmissionRate (supports fractional particles via accumulator)
        let toEmit = effectiveEmissionRate * dt + emissionAccumulator
        let count = Int(floor(toEmit))
        emissionAccumulator = toEmit - Double(count)
        
        // compute angle base using Double values to avoid overload ambiguity
        let angleBase = Darwin.atan2(Double(emissionDirection.dy), Double(emissionDirection.dx))
        
        // compute normalized emission axis and perpendicular in unit-space
        let axisLen = sqrt(Double(emissionDirection.dx * emissionDirection.dx + emissionDirection.dy * emissionDirection.dy))
        let axisX = axisLen > 0 ? Double(emissionDirection.dx) / axisLen : 0.0
        let axisY = axisLen > 0 ? Double(emissionDirection.dy) / axisLen : -1.0
        // perpendicular: rotate by 90deg
        let perpX = -axisY
        let perpY = axisX
        
        for _ in 0..<count {
            if particles.count >= effectiveMaxParticles { break }
            
            // randomize angle within spread (small jitter only)
            let halfSpread = spread / 2.0
            let angle = angleBase + Double.random(in: -halfSpread...halfSpread)
            
            // random speed in unit-space / second (use effectiveSpeedRange)
            let speed = Double.random(in: effectiveSpeedRange)
            
            // velocity components using explicit Darwin trig functions
            let vx = Darwin.cos(angle) * speed
            let vy = Darwin.sin(angle) * speed
            
            // small radial offset in nozzle plane to form base width (use effectiveRadialEmissionRadius)
            let r = Double.random(in: -effectiveRadialEmissionRadius...effectiveRadialEmissionRadius)
            let offsetX = perpX * r
            let offsetY = perpY * r
            
            // random size and hue (use effectiveSizeRange)
            let size = Double.random(in: effectiveSizeRange)
            let hue = Double.random(in: hueRange)
            
            let p = Particle(
                x: Double(center.x) + offsetX,
                y: Double(center.y) + offsetY,
                vx: vx,
                vy: vy,
                size: size,
                hue: hue,
                creationDate: date
            )
            particles.append(p)
        }
        
        // integrate particle motion and apply effects (axis attraction, light drag)
        if dt > 0 {
            // extremely light damping so streaks persist and beam reads continuous
            let dragFactor = pow(0.995, dt * 60.0)
            let cx = Double(center.x)
            let cy = Double(center.y)
            
            for i in particles.indices {
                // basic Euler integration
                particles[i].x += particles[i].vx * dt
                particles[i].y += particles[i].vy * dt
                
                // project particle position onto axis relative to center to compute lateral offset
                let relX = particles[i].x - cx
                let relY = particles[i].y - cy
                // lateral offset (signed) from axis: compute perpendicular component
                let lateral = relX * perpX + relY * perpY
                
                // attract toward axis (pull lateral velocity back toward centerline)
                particles[i].vx -= lateral * axisAttraction * dt * perpX
                particles[i].vy -= lateral * axisAttraction * dt * perpY
                
                // buoyancy (disabled for focused exhaust)
                particles[i].vy += buoyancy * dt * abs(particles[i].size / sizeRange.upperBound)
                
                // apply light drag
                particles[i].vx *= dragFactor
                particles[i].vy *= dragFactor
            }
        }
        
        // remove old or outside particles
        particles.removeAll { p in
            let age = date - p.creationDate
            if age > lifespan { return true }
            // discard if far outside unit box for safety
            if p.x < -0.25 || p.x > 1.25 || p.y < -0.25 || p.y > 1.25 { return true }
            return false
        }
        
        // enforce effectiveMaxParticles cap more strictly if needed
        if particles.count > effectiveMaxParticles {
            let excess = particles.count - effectiveMaxParticles
            particles.removeFirst(excess)
        }
    }
    
    // allow resetting emitter timing (useful when pausing/resuming)
    func reset() {
        particles.removeAll()
        lastUpdateDate = nil
        emissionAccumulator = 0
    }
    
    // Sequence conformance: iterate over a stable snapshot
    struct Iterator: IteratorProtocol {
        private var index = 0
        private let snapshot: [Particle]
        
        init(_ particles: [Particle]) {
            self.snapshot = particles
        }
        
        mutating func next() -> Particle? {
            guard index < snapshot.count else { return nil }
            defer { index += 1 }
            return snapshot[index]
        }
    }
    
    func makeIterator() -> Iterator {
        return Iterator(particles)
    }
}
