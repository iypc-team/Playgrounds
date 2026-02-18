//  ParticleSystem.swift
//  Updated: make ParticleSystem conform to Sequence by returning an Iterator snapshot

import SwiftUI
import Foundation

struct Particle {
    let x: Double
    let y: Double
    let creationDate: TimeInterval = Date.now.timeIntervalSinceReferenceDate
}

final class ParticleSystem: Sequence {
//    let image = Image("star")
    let image = Image("spark")
    private(set) var particles: [Particle] = []
    var center = UnitPoint.center
    
    func update(date: TimeInterval) {
        let newParticle = Particle(x: center.x, y: center.y)
        particles.append(newParticle)
    }
    
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
        // return a snapshot so iteration is stable while the system may mutate
        return Iterator(particles)
    }
}
