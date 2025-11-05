// Copilot RealityKit 11/05/2025-1
// RealityKit sphere with child .usdz MVVM paradigm
// 

import SwiftUI
import RealityKit
import Combine

// MARK: - View
struct RealityKitView: View {
    @StateObject var viewModel: SphereViewModel
    
    var body: some View {
        RealityKitContainer(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
    }
}

struct RealityKitContainer: UIViewRepresentable {
    @ObservedObject var viewModel: SphereViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let rootEntity = AnchorEntity(world: .zero)
        
        let parentEntity = viewModel.assembleParentChild()
        rootEntity.addChild(parentEntity) // Add the sphere and its child
        
        arView.scene.addAnchor(rootEntity)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
}

// MARK: - Preview
struct ContentView: View {
    var body: some View {
        let sphereModel = SphereModel(sphereColor: .red, childUSDZFileName: "childModel")
        let viewModel = SphereViewModel(sphereModel: sphereModel)
        RealityKitView(viewModel: viewModel)
    }
}
