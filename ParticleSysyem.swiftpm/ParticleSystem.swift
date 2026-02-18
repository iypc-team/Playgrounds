//  ParticleSystem.swift
//  

import SwiftUI
import Swift

struct Particle: Hashable {
    let x: Double
    let y: Double
    let creationDate = Date.now.timeIntervalSinceReferenceDate
}

class ParticleSystem: Sequence, IteratorProtocol {
    let image = Image("star.png")
    var particles = Set<Particle>()
    var center = UnitPoint.center
    
    func update(date: TimeInterval) {
        let newParticle = Particle(x: center.x, y: center.y)
        particles.insert(newParticle)
    }
    func makeIterator() -> Self.Iterator {
         
    }
}

