//  ParticleSystem-Metal 02/20/2026- initial commit
//  ContentView.swift
//   Updated: velocity-aligned, stretched particles for jet afterburner look
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/ParticleSysyem.swiftpm
// 
// 

// ContentView.swift
// Replaced Canvas-based renderer with Metal-backed renderer (iOS)
// Assumes MetalParticleView is added to the target.

import SwiftUI

struct ContentView: View {
    @State private var isEngineRunning = true
    @State private var maxParticles: Int = 8000
    
    var body: some View {
        ZStack {
            // Metal-backed particle view (fills the screen)
            MetalParticleView(isRunning: $isEngineRunning, maxParticles: maxParticles)
            //  Cannot find 'MetalParticleView' in scope
                .ignoresSafeArea()
            
            // Overlay controls
            VStack {
                HStack {
                    Spacer()
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
                Spacer()
            }
        }
        .background(Color.black)
    }
    
    private func toggleEngine() {
        isEngineRunning.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
