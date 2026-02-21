//  ParticleSystem-Metal 02/21/2026-2
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/ParticleSystem-Metal.swiftpm

import SwiftUI

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @State private var isEngineRunning = true
    @State private var maxParticles: Int = 8000
    
    var body: some View {
        ZStack {
            // Host the native Metal-backed view on iOS, fallback on other platforms
            MetalParticleHost(isRunning: $isEngineRunning, maxParticles: maxParticles)
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

#if os(iOS)
// Host name chosen to avoid collisions with other wrapper types in the project.
struct MetalParticleHost: UIViewRepresentable {
    @Binding var isRunning: Bool
    var maxParticles: Int
    
    func makeUIView(context: Context) -> UIView {
        // Try both unqualified and module-qualified class names for the native view.
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        let candidates = ["MetalParticleView", "\(bundleName).MetalParticleView"]
        
        for name in candidates {
            if let cls = NSClassFromString(name) as? UIView.Type {
                // Use explicit CGRect.zero to avoid inference issues.
                let view = cls.init(frame: CGRect.zero)
                configureIfPossible(view, maxParticles: maxParticles, isRunning: isRunning)
                return view
            }
        }
        
        // Fallback placeholder used in previews or when native view isn't present.
        let placeholder = UIView(frame: CGRect.zero)
        placeholder.backgroundColor = .black
        return placeholder
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        configureIfPossible(uiView, maxParticles: maxParticles, isRunning: isRunning)
    }
    
    // MARK: - Helpers (best-effort, non-fatal)
    private func configureIfPossible(_ view: UIView, maxParticles: Int, isRunning: Bool) {
        let nsobj: NSObject = view  // UIView already conforms; no conditional cast needed
        
        // Try common setter selectors for an Int property named "maxParticles".
        performSetterIfPossible(nsobj, selectorName: "setMaxParticles:", value: NSNumber(value: maxParticles))
        performSetterIfPossible(nsobj, selectorName: "setParticleCount:", value: NSNumber(value: maxParticles))
        
        // Try common setter selectors for a Bool property named "isRunning"/"running".
        performSetterIfPossible(nsobj, selectorName: "setIsRunning:", value: NSNumber(value: isRunning))
        performSetterIfPossible(nsobj, selectorName: "setRunning:", value: NSNumber(value: isRunning))
        
        // Try calling start/stop API if present.
        if isRunning {
            performSelectorIfAvailable(nsobj, selName: "startEngine")
            performSelectorIfAvailable(nsobj, selName: "start")
        } else {
            performSelectorIfAvailable(nsobj, selName: "stopEngine")
            performSelectorIfAvailable(nsobj, selName: "stop")
        }
    }
    
    private func performSetterIfPossible(_ obj: NSObject, selectorName: String, value: Any) {
        let sel = NSSelectorFromString(selectorName)
        if obj.responds(to: sel) {
            _ = obj.perform(sel, with: value)
        }
    }
    
    private func performSelectorIfAvailable(_ obj: NSObject, selName: String) {
        let sel = NSSelectorFromString(selName)
        if obj.responds(to: sel) {
            _ = obj.perform(sel)
        }
    }
}
#else
// Non-iOS fallback so this file compiles on macOS/watchOS/tvOS SwiftUI previews if needed.
struct MetalParticleHost: View {
    @Binding var isRunning: Bool
    var maxParticles: Int
    
    var body: some View {
        Color.black
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
