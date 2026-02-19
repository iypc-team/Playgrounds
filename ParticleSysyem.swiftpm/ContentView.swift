//  ParticleSystem 02/19/2026-4
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/ParticleSysyem.swiftpm

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
                
                // Use additive blending for a nice glow when sparks overlap
                context.blendMode = .plusLighter
                
                // Guard against invalid lifespan
                guard particleSystem.lifespan > 0 else { return }
                
                for particle in particleSystem {
                    let xPos = particle.x * size.width
                    let yPos = particle.y * size.height
                    
                    // Age-based shrinking / fading
                    let age = timelineDate - particle.creationDate
                    let t = CGFloat(max(0, min(1, age / particleSystem.lifespan))) // 0..1
                    let radius = CGFloat(particle.size) * (1 - t) // shrinks to 0
                    guard radius > 0.01 else { continue }
                    
                    // Core circle
                    let coreRect = CGRect(x: xPos - radius, y: yPos - radius,
                                          width: radius * 2, height: radius * 2)
                    let corePath = Path(ellipseIn: coreRect)
                    context.fill(corePath, with: .color(Color.white.opacity(Double(1 - t))))
                    
                    // Soft glow (larger, lower-opacity circle)
                    let glowRadius = radius * 2.0
                    if glowRadius > 0.5 {
                        let glowRect = CGRect(x: xPos - glowRadius, y: yPos - glowRadius,
                                              width: glowRadius * 2, height: glowRadius * 2)
                        let glowPath = Path(ellipseIn: glowRect)
                        context.fill(glowPath, with: .color(Color.blue.opacity(Double((1 - t) * 0.25))))
                    }
                }
            }
            .drawingGroup()  // rasterize/composite this Canvas on the GPU
        }
        .ignoresSafeArea()
        .background(Color.black)
        .overlay(alignment: .top) {
            Button(action: toggleEngine) {
                Text(isEngineRunning ? "stopEngine" : "startEngine")
                    .font(.system(size: 22, weight: .semibold, design: .default))
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
                particleSystem.emissionRate = savedEmissionRate ?? 600
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
            particleSystem.emissionRate = savedEmissionRate ?? 600
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
