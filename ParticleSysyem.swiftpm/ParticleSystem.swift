// 
import SwiftUI
import Swift

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

