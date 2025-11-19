// 
// 

import RealityKit

class AirplaneModel: ObservableObject {
    @Published var entity: Entity?
    
    func loadModel() {
        Task {
            do {
                // "Airplane" is your .usdz file in the Bundle
                let loadedEntity = try await Entity.load(named: "Airplane")
                DispatchQueue.main.async {
                    self.entity = loadedEntity
                }
            } catch {
                print("Error loading model: \(error)")
            }
        }
    }
}

