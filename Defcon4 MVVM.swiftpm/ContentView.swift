// Defcon4 MVVM  12/26/2025-4
/*
 https://github.com/iypc-team/Playgrounds/tree/main/MVVM%20Defcon4.swiftpm
 */

import SwiftUI
import SceneKit

struct ContentView: View {
    // Observes changes in the ViewModel
    @StateObject var viewModel = SceneViewModel(sceneName: "newFighter.scn")
    
    var body: some View {
        VStack {
            SceneView(scene: viewModel.sceneModel.scene)
            //                .frame(width: 200, height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
                .overlay(
                    Text("SceneKit View")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red.opacity(0.5))
                        .cornerRadius(5),
                    alignment: .top
                )
            
            // Added overlay button aligned to the bottom
                .overlay(
                    Button(action: {
                        viewModel.updateCameraPosition(SCNVector3(x: 0, y: 0, z: 50))
                        // Cannot find 'sceneModel' in scope
                        print("Update Camera Position tapped!")
                    }) {
                        Text("Update Camera Position")
                            .font(.headline)
                            .padding()
                            .background(Color.red.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                        .padding(.bottom, 5),  // Adjust spacing from bottom edge
                    alignment: .bottom
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
