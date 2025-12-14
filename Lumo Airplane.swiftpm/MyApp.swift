// 
// 

// 1️⃣ App entry point
import SwiftUI

@main
struct AirplaneDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AirplaneView()
        }
    }
}

// ├─ AirplaneModel.swift      (Model)
// ├─ AirplaneViewModel.swift  (View‑Model)
// ├─ ARViewContainer.swift    (UIViewRepresentable bridge)
// └─ AirplaneView.swift       (SwiftUI View)
