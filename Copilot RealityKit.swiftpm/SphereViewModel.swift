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
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.25), materials: [SimpleMaterial(color: sphereModel.sphereColor, isMetallic: false)])
        return sphere
    }
    
    func loadUSDZEntity() -> Entity? {
        let bs = Bundle.allFrameworks
        print("allFrameworks.count:  \(bs.count)\n")
        for bundle in Bundle.allFrameworks {
//            print("\(String(describing: bundle.bundleIdentifier))")
//            print("\(bundle.bundlePath)\n")
        }
        
        guard let modelURL = Bundle.main.url(forResource: sphereModel.childUSDZFileName, withExtension: "usdz") else {
            print("Failed to load USDZ file\n")
            return nil
        }
        
        print("modelURL: \(modelURL)")
        
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

