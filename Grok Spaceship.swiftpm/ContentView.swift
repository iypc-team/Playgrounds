// Grok Spaceship  11/22/2025-3
// SwiftUI + RealityKit, MVVM, iOS 16, loadModel(Airplane.usdz), lighting, gesture, recognizers, 

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RealityKitViewModel()
    
    var body: some View {
        RealityKitView(modelName: "Spaceship.usdz", rotation: $viewModel.rotation)
            .frame(width: 500, height: 500)
    }
}

class Print {
    let msg = "ContentView"
    let view = ContentView()
    let body = ContentView()
    init() {
        print(msg)
        print(view)
    }
    
    //    func msg() { print("ContentView") }
}
