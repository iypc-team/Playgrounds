//  Defcon4 SwiftUi 10/31/2025-initial commit
//  

import SwiftUI

struct ContentView: View {
    // Keep the scene in a @StateObject if you plan to modify it later
    private let demoScene = makeDemoScene()
    
    var body: some View {
        VStack {
            Text("SceneKit in SwiftUI")
                .font(.headline)
                .padding()
            
            // The SceneKit view fills the remaining space
            SceneKitView(scene: demoScene,
                         allowsCameraControl: true,
                         backgroundColor: .darkGray)
            .edgesIgnoringSafeArea(.all)   // optional, for full‑screen
        }
    }
}

