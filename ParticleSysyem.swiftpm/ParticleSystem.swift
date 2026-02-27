//
//  ParticleSystem.swift
//  Updated: ParticleSystem now conforms to ObservableObject so it can be used with @StateObject.
//  Note: particles are intentionally NOT @Published (updated every frame) to avoid flooding SwiftUI with change events.
//  Import SwiftUI so ObservableObject and Image are available.
//

import SwiftUI
import Foundation

// MARK: - Constants

private enum PSConstants {
    /// Default particle lifetime (seconds). Approximately 0.16 s.
    static let defaultLifespan: TimeInterval = 0.16
    
    /// Minimum allowed global scale (prevents silent zero‑scale bugs).
    static let minGlobalScale: Double = 0.0
    
    /// Margin beyond the unit‑space view in which particles are culled.
    static let removalMargin: Double = 0.25
    
    /// Base drag factor applied per 60 fps frame.
    static let dragPerFrame: Double = 0.995
    
    /// Target frame rate used for drag calculations.
    static let targetFPS: Double = 60.0
}

// MARK: - Particle Model

struct Particle {
    var x: Double          // unit‑space coordinates (0…1) relative to drawing container
    var y: Double
    
    var vx: Double         // velocity in unit‑space per second
    var vy: Double
    
    let size: Double       // initial size in points (used by drawing code)
    
    let hue: Double        // hue (0…1) for colour mapping
    
    let creationDate: TimeInterval   // creation timestamp
}

// MARK: - Particle System

/// A lightweight, observable particle system suitable for SwiftUI previews.
///
/// The system updates its internal particle list each frame but does **not**
/// publish the list directly to avoid overwhelming SwiftUI. Instead, an optional
/// `particleCount` publisher is provided for UI elements that need a simple
/// change notification.
final class ParticleSystem: ObservableObject, Sequence {
    
    // --------------------------------------------------------------------
    // MARK: - Public Configuration (observable)
    
    /// Origin of emitted particles (unit coordinates). Default is near the bottom‑center.
    @Published var center: UnitPoint = .init(x: 0.5, y: 0.88)
    
    /// How long a particle lives (seconds). Default ≈ 0.16 s.
    @Published var lifespan: TimeInterval = PSConstants.defaultLifespan
    
    /// Base emission rate (particles / second) before scaling.
    @Published var emissionRate: Double = 700 * 5               // 3500 p/s (base)
    
    /// Direction vector of the emission axis. Changing this marks the cached axis dirty.
    @Published var emissionDirection: CGVector = CGVector(dx: -1.0, dy: 0.0) {
        didSet { emissionDirectionDirty = true }
    }
    
    /// Angular spread of the beam (radians). Very narrow by default.
    @Published var spread: Double = .pi * 0.01
    
    /// Speed range (unit‑space / s) before scaling.
    @Published var speedRange: ClosedRange<Double> = 3.0...6.0
    
    /// Size range (points) before scaling.
    @Published var sizeRange: ClosedRange<Double> = 0.5...1.1
    
    /// Hue range for colour mapping.
    @Published var hueRange: ClosedRange<Double> = 0.58...0.66
    
    /// Hard cap on total particles (base value, later scaled).
    @Published var maxParticles: Int = 8000
    
    // Geometry & motion tuning (base values)
    
    /// Half‑width of the nozzle in unit‑space (base value). Scaled by `globalScale`.
    @Published var nozzleHalfWidth: Double = 0.003 / 4
    
    /// Restoring strength toward the emission axis (spring‑like).
    @Published var axisRestoringStrength: Double = 6.0
    
    /// Additional restoring strength that can be added at runtime.
    @Published var lateralBoost: Double = 0.0
    
    /// Upward buoyancy applied proportionally to particle size.
    @Published var buoyancy: Double = 0.0
    
    /// Global scaling factor that multiplies emission rate, speeds, sizes, and nozzle width.
    ///
    /// Values ≤ 1 shrink the stream; 1.0 is the default.
    @Published var globalScale: Double = 1.0 / 5.0 {
        didSet {
            // Clamp to a safe range (negative or NaN values become zero).
            if globalScale.isNaN || globalScale < PSConstants.minGlobalScale {
                globalScale = PSConstants.minGlobalScale
            }
        }
    }
    
    // --------------------------------------------------------------------
    // MARK: - Private State
    
    /// Optional lightweight observable for UI that only needs to know the particle count.
    @Published private(set) var particleCount: Int = 0
    
    /// Internal particle storage (updated each frame, not published directly).
    private var particles: [Particle] = []
    
    /// Timestamp of the previous update call.
    private var lastUpdateDate: TimeInterval?
    
    /// Accumulator for fractional particles across frames.
    private var emissionAccumulator: Double = 0
    
    /// Cached direction vector and base angle for the emission axis.
    private var emissionDirectionDirty = true
    private var cachedAxis = SIMD2<Double>(0, -1)          // unit vector
    private var cachedAngleBase = -Double.pi / 2           // corresponds to (0, -1)
    
    // --------------------------------------------------------------------
    // MARK: - Public Convenience Properties
    
    /// True when there are no particles currently alive.
    var isEmpty: Bool { particles.isEmpty }
    
    /// Determines whether the emitter is considered active.
    ///
    /// Active if the scaled emission rate is non‑zero **or** any particles remain.
    var isActive: Bool {
        (emissionRate * globalScale) > 0 || !particles.isEmpty
    }
    
    // --------------------------------------------------------------------
    // MARK: - Rendering Helpers
    
    /// Placeholder image for sprite‑based rendering (kept for compatibility).
    let image = Image("star")
    
    // --------------------------------------------------------------------
    // MARK: - Core Update Loop
    
    /// Call once per frame with `timeline.date.timeIntervalSinceReferenceDate`.
    ///
    /// - Parameter date: Current time expressed as a reference‑date interval.
    func update(date: TimeInterval) {
        // ------------------------------------------------------------
        // Early‑out when completely stopped.
        if (emissionRate * globalScale) == 0 && particles.isEmpty {
            lastUpdateDate = nil
            particleCount = 0
            return
        }
        
        // Initialise `lastUpdateDate` on the first call (or after a pause).
        guard let last = lastUpdateDate else {
            lastUpdateDate = date
            return
        }
        
        // ------------------------------------------------------------
        // Compute delta‑time and clamp to a sensible maximum to keep the simulation stable.
        let rawDt = Swift.max(0, date - last)
        let maxDt: TimeInterval = 1.0 / 15.0                 // ≈ 66 ms
        let dt = Swift.min(rawDt, maxDt)
        lastUpdateDate = date
        
        // ------------------------------------------------------------
        // Apply global scaling to derived parameters.
        let effectiveEmissionRate = emissionRate * globalScale
        let effectiveSpeedRange = (speedRange.lowerBound * globalScale)...(speedRange.upperBound * globalScale)
        let effectiveSizeRange = (sizeRange.lowerBound * globalScale)...(sizeRange.upperBound * globalScale)
        let effectiveNozzleHalfWidth = nozzleHalfWidth * globalScale
        let effectiveMaxParticles = Swift.max(16, Int(Double(maxParticles) * Swift.max(globalScale, 0.01)))
        
        // Reserve capacity if needed (reduces reallocations during heavy emission).
        if particles.capacity < effectiveMaxParticles {
            particles.reserveCapacity(effectiveMaxParticles)
        }
        
        // ------------------------------------------------------------
        // Emit new particles based on the scaled emission rate.
        let toEmit = effectiveEmissionRate * dt + emissionAccumulator
        let emitCount = Int(floor(toEmit))
        emissionAccumulator = toEmit - Double(emitCount)
        
        // Update cached axis/angle if the direction vector changed.
        if emissionDirectionDirty {
            let dx = Double(emissionDirection.dx)
            let dy = Double(emissionDirection.dy)
            let length = hypot(dx, dy)
            if length > 0 {
                cachedAxis = SIMD2<Double>(dx / length, dy / length)
            } else {
                cachedAxis = SIMD2<Double>(0, -1)
            }
            cachedAngleBase = atan2(cachedAxis.y, cachedAxis.x)
            emissionDirectionDirty = false
        }
        
        // Pre‑compute values used inside the emission loop.
        let perp = SIMD2<Double>(-cachedAxis.y, cachedAxis.x)   // perpendicular to the axis
        let halfSpread = spread / 2.0
        let cx = Double(center.x)
        let cy = Double(center.y)
        
        for _ in 0..<emitCount {
            if particles.count >= effectiveMaxParticles { break }
            
            // Random angle within the narrow spread.
            let angle = cachedAngleBase + Double.random(in: -halfSpread...halfSpread)
            
            // Random speed within the scaled range.
            let speed = Double.random(in: effectiveSpeedRange)
            
            // Velocity components.
            let vx = cos(angle) * speed
            let vy = sin(angle) * speed
            
            // Radial offset inside the nozzle half‑width.
            let r = Double.random(in: -effectiveNozzleHalfWidth...effectiveNozzleHalfWidth)
            let offsetX = perp.x * r
            let offsetY = perp.y * r
            
            // Random size and hue.
            let size = Double.random(in: effectiveSizeRange)
            let hue = Double.random(in: hueRange)
            
            let particle = Particle(
                x: cx + offsetX,
                y: cy + offsetY,
                vx: vx,
                vy: vy,
                size: size,
                hue: hue,
                creationDate: date
            )
            particles.append(particle)
        }
        
        // ------------------------------------------------------------
        // Integrate motion and apply forces (restoring, buoyancy, drag).
        if dt > 0 {
            // Light drag factor based on the target FPS.
            let dragFactor = pow(PSConstants.dragPerFrame, dt * PSConstants.targetFPS)
            
            // Combined restoring strength.
            let restoring = axisRestoringStrength + lateralBoost
            
            for i in particles.indices {
                // Basic Euler integration.
                particles[i].x += particles[i].vx * dt
                particles[i].y += particles[i].vy * dt
                
                // Lateral offset from the central axis.
                let relX = particles[i].x - cx
                let relY = particles[i].y - cy
                let lateral = relX * perp.x + relY * perp.y
                
                // Spring‑like restoring towards the axis.
                particles[i].vx -= lateral * restoring * dt * perp.x
                particles[i].vy -= lateral * restoring * dt * perp.y
                
                // Buoyancy scaled by particle size.
                if effectiveSizeRange.upperBound > 0 {
                    particles[i].vy += buoyancy * dt * (particles[i].size / effectiveSizeRange.upperBound)
                } else {
                    particles[i].vy += buoyancy * dt
                }
                
                // Apply drag.
                particles[i].vx *= dragFactor
                particles[i].vy *= dragFactor
            }
        }
        
        // ------------------------------------------------------------
        // Cull old or out‑of‑bounds particles (in‑place compaction).
        var writeIdx = 0
        for readIdx in 0..<particles.count {
            let p = particles[readIdx]
            let age = date - p.creationDate
            var keep = true
            
            if age > lifespan { keep = false }
            if p.x < -PSConstants.removalMargin ||
                p.x > 1 + PSConstants.removalMargin ||
                p.y < -PSConstants.removalMargin ||
                p.y > 1 + PSConstants.removalMargin {
                keep = false
            }
            
            if keep {
                if writeIdx != readIdx {
                    particles[writeIdx] = p
                }
                writeIdx += 1
            }
        }
        
        if writeIdx < particles.count {
            particles.removeLast(particles.count - writeIdx)
        }
        
        // Enforce strict max‑particle cap (trim oldest if necessary).
        if particles.count > effectiveMaxParticles {
            let excess = particles.count - effectiveMaxParticles
            particles.removeFirst(excess)
        }
        
        // Update the lightweight observable.
        particleCount = particles.count
    }
    
    // --------------------------------------------------------------------
    // MARK: - Reset
    
    /// Clears all particles and resets internal timers.
    ///
    /// Configuration properties (e.g., `globalScale`, `emissionRate`) are **not** altered.
    func reset() {
        particles.removeAll()
        lastUpdateDate = nil
        emissionAccumulator = 0
        particleCount = 0
    }
    
    // --------------------------------------------------------------------
    // MARK: - Sequence Conformance
    
    func makeIterator() -> IndexingIterator<[Particle]> {
        particles.makeIterator()
    }
}
