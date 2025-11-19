// 
// 

import SwiftUI
import RealityKit

class SpaceshipViewModel: ObservableObject {
    @Published var modelEntity: ModelEntity?
    
    func loadModel() {
        Task {
            do {
                let entity = try await Entity.load(named: "Spaceship.usdz") as? ModelEntity
                await MainActor.run {
                    self.modelEntity = entity
                }
            } catch {
                print("Failed to load: \(error)")
            }
        }
    }
}

