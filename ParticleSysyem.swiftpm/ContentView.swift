// 04/05/2023
// https://www.youtube.com/watch?v=raR-hDgzoFg

import SwiftUI

struct ContentView: View {
    @State private var particleSystem = ParticleSystem()
    var body: some View {
        TimelineView<AnimationTimelineSchedule, { timeline in }
            Canvas { context, size in
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate)
                
                for particle in particleSystem {
                    let xPos = particle.x * size.width
                    let yPos = particle.y * size.height
                    
                    context.draw(particleSystem.image, at: CGPoint(x: xPos, y: yPos))
                }
            }
        }
        .ignoresSafeArea()
        .background(.black)
    }
}


struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}


