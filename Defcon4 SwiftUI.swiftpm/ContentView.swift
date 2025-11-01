//  Defcon4 SwiftUi 11/01/2025-2
//  

import SwiftUI

struct ContentView: View {
    // Keep the scene in a @StateObject if you plan to modify it later
    private let demoScene = makeDemoScene()
    
    var body: some View {
        VStack {
            // The SceneKit view fills the remaining space
            SceneKitView(scene: demoScene,
                         allowsCameraControl: true,
                         backgroundColor: .darkGray)
            .edgesIgnoringSafeArea(.all)   // optional, for full‑screen
        }
    }
}

