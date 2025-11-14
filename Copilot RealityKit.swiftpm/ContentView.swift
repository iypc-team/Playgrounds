// Copliot RealityKit  11/14/2025-2
// iOS 16 RealityKit model Airplane.usdz No ARView. MVVM paradigm implementation skeleton
// 

import SwiftUI
import SceneKit

struct AirplaneView: View {
    @StateObject var vm = AirplaneViewModel()
    
    var body: some View {
        VStack {
            SceneKitContainer(scene: vm.scnScene)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Button("Load (SceneKit)") {
                    print("Button(Load (SceneKit))")
                    vm.loadForSceneKit()
                }
                .background(Color.green)

                Button("Load (RealityKit)") {
                    print("Button(Load (RealityKit))")
                    vm.loadForRealityKit()
                }
                .background(Color.green)
                
                Button("Load Both") {
                    print("Button(Load Both)")
                    vm.loadAll()
                }
                .background(Color.yellow)
            }
            .padding(10)
        }
        .onAppear { vm.loadForSceneKit() }  // auto-load
    }
}

//struct SceneKitContainer: UIViewRepresentable {
//    var scene: SCNScene?
//    
//    func makeUIView(context: Context) -> SCNView {
//        let scnView = SCNView(frame: .zero)
//        scnView.allowsCameraControl = true
//        scnView.backgroundColor = .systemBackground
//        scnView.autoenablesDefaultLighting = true
//        scnView.scene = scene
//        // Optionally create a camera if your USDZ lacks one
//        if scnView.scene?.rootNode.childNode(withName: "camera", recursively: true) == nil {
//            let cameraNode = SCNNode()
//            cameraNode.camera = SCNCamera()
//            cameraNode.position = SCNVector3(x: 0, y: 0, z: 10) // adjust as needed
//            scnView.scene?.rootNode.addChildNode(cameraNode)
//        }
//        return scnView
//    }
//    
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // Swap scene when ViewModel updates
//        if uiView.scene !== scene {
//            uiView.scene = scene
//        }
//    }
//}

