// 
// 

import SwiftUI
import RealityKit
import Combine

// MARK: - ViewModel
class SphereViewModel: ObservableObject {
    @Published var sphereModel: SphereModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(sphereModel: SphereModel) {
        self.sphereModel = sphereModel
    }
    
    func createSphereEntity() -> Entity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.5), materials: [SimpleMaterial(color: sphereModel.sphereColor, isMetallic: false)])
        return sphere
    }
    
    func loadUSDZEntity() -> Entity? {
        let bs = Bundle.allBundles.description
        print("\(bs)")
        
        guard let modelURL = Bundle.main.url(forResource: sphereModel.childUSDZFileName, withExtension: "usdz") else {
            print("Failed to load USDZ file")
            return nil
        }
        
        if let usdzEntity = try? Entity.loadModel(contentsOf: modelURL) {
            usdzEntity.position = sphereModel.childPosition
            return usdzEntity
        }
        return nil
    }
    
    func assembleParentChild() -> Entity {
        let parent = createSphereEntity()
        
        if let child = loadUSDZEntity() {
            parent.addChild(child)
        }
        
        return parent
    }
}

