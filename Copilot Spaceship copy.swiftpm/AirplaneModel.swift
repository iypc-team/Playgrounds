// 
// bullshit
// 

import SwiftUI
import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    
    func loadModel() {
        Task {
            do {
                // "Airplane" is your .usdz file in the Bundle
                let loadedEntity = try await Entity.load(named: "Spaceship")
                
                DispatchQueue.main.async {
                    self.entity = loadedEntity
                }
            } catch {
                print("Error loading model: \(error.localizedDescription)")
            }
        }
    }
    
    func rotateModel() {
        print("func rotateModel() called")
        let realityKitView = RealityKitView(entity: self.entity)
        Task {
            await realityKitView.rotateModelCumulatively(self.entity!, by: 22.5) // Adjust angle as needed
        }
        //        RealityKitView.rotateModelCumulatively(model: Entity, by angleDegrees: Float = 22.5)
    }
}
