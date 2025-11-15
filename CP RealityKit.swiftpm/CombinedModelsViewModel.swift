// 
// 

import Combine
import RealityKit

class CombinedModelsViewModel: ObservableObject {
    @Published var airplaneEntity: Entity?
    @Published var spaceshipEntity: Entity?
    
    private var modelLoader = RealityModelLoader()
    
    func loadAirplane() {
        modelLoader.loadModel(named: "Airplane.usdz") { [weak self] entity in
            self?.airplaneEntity = entity
        }
    }
    
    func loadSpaceship() {
        modelLoader.loadModel(named: "Spaceship.usdz") { [weak self] entity in
            self?.spaceshipEntity = entity
        }
    }
    
    func loadBothModels() {
        loadAirplane()
        loadSpaceship()
    }
}

