//  ParticleSystem 02/26/2026-3
//  ContentView.swift
//   Updated: velocity-aligned, stretched particles for jet afterburner look
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/ParticleSysyem.swiftpm
// 

import SwiftUI

struct ContentView: View {
    @State private var particleSystem = ParticleSystem()
    @State private var isEngineRunning = true
    @State private var savedEmissionRate: Double? = nil
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate)
                
                // additive blending for bright cores and glow
                context.blendMode = .plusDarker
                
                // Guard against invalid lifespan
                guard particleSystem.lifespan > 0 else { return }
                
                let viewScale = Swift.max(size.width, size.height)
                
                for particle in particleSystem {
                    let xPos = particle.x * size.width
                    let yPos = particle.y * size.height
                    
                    // Age-based factor
                    let age = timelineDate - particle.creationDate
                    let t = CGFloat(Swift.max(0, Swift.min(1, age / particleSystem.lifespan))) // 0..1
                    
                    // base radius (core)
                    let baseRadius = CGFloat(particle.size) * (1 - t * 0.6)
                    guard baseRadius > 0.01 else { continue }
                    
                    // velocity & orientation
                    let vx = CGFloat(particle.vx)
                    let vy = CGFloat(particle.vy)
                    let speed = hypot(vx, vy)
                    
                    // approximate speed in points (unit-space -> points)
                    let speedPoints = speed * viewScale
                    
                    // elongation based on speed
                    let lengthScale = 1.0 + Swift.min(speedPoints * 0.025, 14.0)
                    
                    // angle aligned with velocity. fallback to up
                    var angle = atan2(vy, vx)
                    if speedPoints < 0.0001 { angle = -.pi / 2 }
                    
                    // create a small ellipse centered at origin, then transform
                    let w = baseRadius * 2.0
                    let h = Swift.max(baseRadius * 0.45, 0.5) // thin cross-axis
                    let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
                    
                    var transform = CGAffineTransform(translationX: xPos, y: yPos)
                    transform = transform.rotated(by: angle)
                    transform = transform.scaledBy(x: lengthScale, y: 1.0)
                    
                    let corePath = Path(ellipseIn: rect).applying(transform)
                    
                    // white core, bright and short-lived
                    let coreOpacity = Double(Swift.max(0.0, 1.0 - t * 1.4))
                    context.fill(corePath, with: .color(Color.white.opacity(coreOpacity)))
                    
                    // Outer glow (tinted by particle hue). Larger and softer.
                    let glowRadius = baseRadius * 4.0 * CGFloat(lengthScale)
                    if glowRadius > 0.5 {
                        let glowRect = CGRect(x: xPos - glowRadius, y: yPos - glowRadius,
                                              width: glowRadius * 2, height: glowRadius * 2)
                        let glowColor = Color(hue: particle.hue, saturation: 0.95, brightness: 0.95,
                                              opacity: Double((1 - t) * 0.18))
                        context.fill(Path(ellipseIn: glowRect), with: .color(glowColor))
                    }
                }
            }
            .drawingGroup() // rasterize/composite this Canvas on the GPU
        }
        .ignoresSafeArea()
        .background(Color.black)
        .overlay(alignment: .bottom) {
            Button(action: toggleEngine) {
                Text(isEngineRunning ? "stopEngine" : "startEngine")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
            }
            .padding()
        }
        .onAppear {
            // Ensure emission state is applied when the view appears
            if isEngineRunning {
                particleSystem.emissionRate = savedEmissionRate ?? particleSystem.emissionRate
                savedEmissionRate = nil
            } else {
                // keep previously stored emission rate and ensure emission is stopped
                savedEmissionRate = particleSystem.emissionRate
                particleSystem.emissionRate = 0
            }
        }
        .onDisappear {
            // Stop emission when view disappears to avoid unnecessary work
            savedEmissionRate = particleSystem.emissionRate
            particleSystem.emissionRate = 0
        }
    }
    
    private func toggleEngine() {
        if isEngineRunning {
            // stop emission: save current rate and set to zero
            savedEmissionRate = particleSystem.emissionRate
            particleSystem.emissionRate = 0
        } else {
            // restore previously saved emission rate (or default)
            particleSystem.emissionRate = savedEmissionRate ?? particleSystem.emissionRate
            savedEmissionRate = nil
        }
        isEngineRunning.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
