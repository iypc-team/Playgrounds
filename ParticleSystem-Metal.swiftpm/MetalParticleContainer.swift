import SwiftUI

#if os(iOS)
import UIKit
#endif

#if os(iOS)
struct MetalParticleContainer: UIViewRepresentable {
    @Binding var isRunning: Bool
    var maxParticles: Int
    
    func makeUIView(context: Context) -> UIView {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        let candidates = ["MetalParticleView", "\(bundleName).MetalParticleView"]
        
        for name in candidates {
            if let cls = NSClassFromString(name) as? UIView.Type {
                // Use explicit CGRect.zero to avoid "Cannot infer contextual base" errors
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
    
    // MARK: - Helpers
    
    private func configureIfPossible(_ view: UIView, maxParticles: Int, isRunning: Bool) {
        let nsobj = view as NSObject
        
        performSetterIfPossible(nsobj, selectorName: "setMaxParticles:", value: NSNumber(value: maxParticles))
        performSetterIfPossible(nsobj, selectorName: "setParticleCount:", value: NSNumber(value: maxParticles))
        
        performSetterIfPossible(nsobj, selectorName: "setIsRunning:", value: NSNumber(value: isRunning))
        performSetterIfPossible(nsobj, selectorName: "setRunning:", value: NSNumber(value: isRunning))
        
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
struct MetalParticleContainer: View {
    @Binding var isRunning: Bool
    var maxParticles: Int
    
    var body: some View {
        Color.black
    }
}
#endif
