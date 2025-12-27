// Defcon4 MVVM  12/27/2025-2
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Text("SceneKit View")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red.opacity(0.5))
                        .cornerRadius(5),
                    alignment: .top
                )
        }
        .overlay(
            HStack {
                Button(action: {
                    if let currentPosition = viewModel.sceneModel.cameraNode?.position {
                        let newPosition = SCNVector3(x: currentPosition.x, y: currentPosition.y, z: currentPosition.z - 10)
                        viewModel.updateCameraPosition(newPosition)
                        print("Added 10 to camera Z position!")
                        print("Camera.position: \(String(describing: viewModel.sceneModel.cameraNode?.position ))")
                    }
                }) {
                    Text("Plus Camera Position")
                        .padding()
                        .background(Color.red.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    if let currentPosition = viewModel.sceneModel.cameraNode?.position {
                        let newPosition = SCNVector3(x: currentPosition.x, y: currentPosition.y, z: currentPosition.z + 10)
                        viewModel.updateCameraPosition(newPosition)
                        print("Added 10 to camera Z position!")
                        print("Camera.position: \(String(describing: viewModel.sceneModel.cameraNode?.position ))")
                    }
                }) {
                    Text("Minus Camera Position")
                        .padding()
                        .background(Color.blue.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
                .padding(.bottom, 5),
            alignment: .bottom
        )
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
