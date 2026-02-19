// ParticleSystem.swift
// Updated: many-particle flowing emitter (jet-engine exhaust style)
// Fixes: avoid "Ambiguous use of 'cos'/'sin'" by calling Darwin.cos / Darwin.sin explicitly.

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
    
    // hue (0..1) for color mapping (optional - e.g. orange -> yellow hues)
    let hue: Double
    
    // creation timestamp
    let creationDate: TimeInterval
}

final class ParticleSystem: Sequence {
    // Particles
    private(set) var particles: [Particle] = []
    
    // Where particles originate (unit coordinates)
    var center: UnitPoint = .center
//    var center: UnitPoint = .init(x: 0.5, y: 0.9) // bottom-center (engine outlet)
    
    // How long a particle lives (seconds)
    var lifespan: TimeInterval = 1.6
    
    // Emission properties
    var emissionRate: Double = 600                    // particles per second
    var emissionDirection: CGVector = CGVector(dx: 0.0, dy: -1.0) // default: up (-y)
    var spread: Double = .pi * 0.35                   // angular spread (radians)
    var speedRange: ClosedRange<Double> = 0.25...1.2  // unit-space per second
    var sizeRange: ClosedRange<Double> = 2.0...6.0    // points
    var hueRange: ClosedRange<Double> = 0.08...0.12   // color hue range
    var maxParticles: Int = 6000                      // safety cap
    
    // internal bookkeeping
    private var lastUpdateDate: TimeInterval?
    private var emissionAccumulator: Double = 0
    
    // optional image kept for compatibility if you choose to use sprites instead of shapes
    let image = Image("spark")
    
    /// Call once per frame with timeline.date.timeIntervalSinceReferenceDate
    func update(date: TimeInterval) {
        // initialize lastUpdateDate on first call
        guard let last = lastUpdateDate else {
            lastUpdateDate = date
            return
        }
        
        let dt = Swift.max(0, date - last)
        lastUpdateDate = date
        
        // spawn particles according to emissionRate (supports fractional particles via accumulator)
        let toEmit = emissionRate * dt + emissionAccumulator
        let count = Int(floor(toEmit))
        emissionAccumulator = toEmit - Double(count)
        
        // compute angle base using Double values to avoid overload ambiguity
        let angleBase = Darwin.atan2(Double(emissionDirection.dy), Double(emissionDirection.dx))
        
        for _ in 0..<count {
            if particles.count >= maxParticles { break }
            
            // randomize angle within spread
            let halfSpread = spread / 2.0
            let angle = angleBase + Double.random(in: -halfSpread...halfSpread)
            
            // random speed in unit-space / second
            let speed = Double.random(in: speedRange)
            
            // velocity components using explicit Darwin trig functions
            let vx = Darwin.cos(angle) * speed
            let vy = Darwin.sin(angle) * speed
            
            // random size and hue
            let size = Double.random(in: sizeRange)
            let hue = Double.random(in: hueRange)
            
            let p = Particle(
                x: Double(center.x),
                y: Double(center.y),
                vx: vx,
                vy: vy,
                size: size,
                hue: hue,
                creationDate: date
            )
            particles.append(p)
        }
        
        // integrate particle motion and apply simple effects (drag, slight turbulence)
        if dt > 0 {
            // drag coefficient per frame (smaller -> heavier damping)
            let dragFactor = pow(0.85, dt * 60.0) // frame-rate-normalized-ish damping
            let cx = Double(center.x)
//            let cy = Double(center.y)
            
            for i in particles.indices {
                // basic Euler integration
                particles[i].x += particles[i].vx * dt
                particles[i].y += particles[i].vy * dt
                
                // slight turbulence / lateral spreading to mimic exhaust mixing:
                let dx = particles[i].x - cx
                let lateralBoost = 0.25
                particles[i].vx += dx * lateralBoost * dt
                
                // optional upward buoyancy effect (helps the plume rise)
                let buoyancy: Double = -0.3
                particles[i].vy += buoyancy * dt * abs(particles[i].size / sizeRange.upperBound)
                
                // apply drag
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
        
        // enforce maxParticles cap more strictly if needed
        if particles.count > maxParticles {
            let excess = particles.count - maxParticles
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
