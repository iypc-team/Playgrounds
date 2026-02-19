// ParticleSystem.swift
// Updated: tuned for narrow, high-speed exhaust (afterburner style)

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
    var center: UnitPoint = .init(x: 0.5, y: 0.85)
    
    // How long a particle lives (seconds)
    var lifespan: TimeInterval = 0.35
    
    // Emission properties tuned for narrow, fast exhaust
    var emissionRate: Double = 900                    // particles per second (bursty/high flux)
    var emissionDirection: CGVector = CGVector(dx: 0.0, dy: -1.0) // up (negative y)
    var spread: Double = .pi * 0.08                   // narrow cone (~9° half-angle)
    var speedRange: ClosedRange<Double> = 1.8...3.6   // unit-space per second (fast)
    var sizeRange: ClosedRange<Double> = 1.5...3.5    // smaller core sizes
    var hueRange: ClosedRange<Double> = 0.58...0.66   // bluish tint (adjust for orange if desired)
    var maxParticles: Int = 12000                     // safety cap
    
    // Motion tuning
    var lateralBoost: Double = 0.05   // reduced lateral spreading (keeps plume narrow)
    var buoyancy: Double = 0.0        // disable upward billowing for exhaust
    
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
            // much lighter damping so streaks persist longer
            let dragFactor = pow(0.98, dt * 60.0) // frame-rate-normalized-ish damping
            let cx = Double(center.x)
            
            for i in particles.indices {
                // basic Euler integration
                particles[i].x += particles[i].vx * dt
                particles[i].y += particles[i].vy * dt
                
                // reduced lateral spreading to keep the exhaust narrow
                let dx = particles[i].x - cx
                particles[i].vx += dx * lateralBoost * dt
                
                // optional buoyancy (disabled by default for exhaust)
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
