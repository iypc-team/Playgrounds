// 

import SwiftUI
import RealityKit

class ModelViewModel: ObservableObject {
    @Published var entity: Entity?
    
    func loadModel() {
        Task {
            if let loaded = try? await Entity.load(named: "Spaceship.usdz") {
                DispatchQueue.main.async {
                    self.entity = loaded
                }
            }
        }
    }
}

