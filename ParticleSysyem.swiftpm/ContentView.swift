//  ParticleSystem 02/18/2026-3
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/ParticleSysyem.swiftpm

import SwiftUI

struct ContentView: View {
    @State private var particleSystem = ParticleSystem()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate)
                
                let image = particleSystem.image
                for particle in particleSystem {
                    let xPos = particle.x * size.width
                    let yPos = particle.y * size.height
                    context.draw(image, at: CGPoint(x: xPos, y: yPos))
                }
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
