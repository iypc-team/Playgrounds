// Defcon4 MVVM  12/26/2025-3
/*
 https://github.com/iypc-team/Playgrounds/tree/main/MVVM%20Defcon4.swiftpm
 */

import SwiftUI
import SceneKit

struct ContentView: View {
    // Observes changes in the ViewModel
    @StateObject var viewModel = SceneViewModel(sceneName: "fighter.scn")
    
    var body: some View {
        VStack {
            SceneView(scene: viewModel.sceneModel.scene)
//                .frame(width: 200, height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
                .overlay(
                    Text("SceneKit View")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(5),
                    alignment: .top
                )
                
            
        }
    }
}

// SCNView as a SwiftUI View
struct SceneView: UIViewRepresentable {
    var scene: SCNScene?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.black
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
