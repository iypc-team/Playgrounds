// Defcon4 MVVM  12/28/2025-1
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
                        .background(Color.red.opacity(0.1))
                        .padding(4)
                        .cornerRadius(5),
                    alignment: .top
                )
        }
        .overlay(
            HStack {
                Button(action: {
                    viewModel.cameraPositionPlus(SCNVector3(x: 0, y: 0, z: -10))
                    print("Added 10 to camera Z position!")
                    print("Camera.position: \(String(describing: viewModel.sceneModel.cameraNode?.position))")
                }) {
                    Text("Plus Camera Position")
                        .padding()
                        .background(Color.red.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    viewModel.cameraPositionMinus(SCNVector3(x: 0, y: 0, z: 10))
                    print("Added 10 to camera Z position!")
                    print("Camera.position: \(String(describing: viewModel.sceneModel.cameraNode?.position))")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
