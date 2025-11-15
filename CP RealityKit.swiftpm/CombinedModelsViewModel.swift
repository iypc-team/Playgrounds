// 
// 

import Combine
import RealityKit

class CombinedModelsViewModel: ObservableObject {
    @Published var airplaneEntity: Entity? = nil
    @Published var spaceshipEntity: Entity? = nil
    
    func loadAirplane() {
        airplaneEntity = RealityModelLoader.loadModel(named: "Airplane.usdz")
    }
    
    func loadSpaceship() {
        spaceshipEntity = RealityModelLoader.loadModel(named: "Spaceship.usdz")
    }
    
    func loadBothModels() {
        loadAirplane()
        loadSpaceship()
    }
}

