// 
// 

import RealityKit

class AirplaneViewModel {
    // Observable property for the 3D Entity
    private(set) var airplaneEntity: ModelEntity?
    
    init() {
        loadAirplaneModel()
    }
    
    private func loadAirplaneModel2() {
        do {
            let modelEntity = try ModelEntity.load(named: "Airplane")
            print("Airplane model loaded successfully!")
            
            // Customize its position, scale, etc.
            modelEntity.position = SIMD3(x: 0, y: 0.1, z: -1) // Move slightly above ground and further into view.
            modelEntity.scale = SIMD3(repeating: 1.0)
            
            self.airplaneEntity = modelEntity
        } catch {
            print("Failed to load Airplane.usdz: \(error.localizedDescription)")
        }
    }
    
    // Load the airplane from the .usdz file
    private func loadAirplaneModel() {
        guard let modelEntity = try? ModelEntity.load(named: "Airplane.usdz") else {
            print("Failed to load Airplane.usdz")
            return
        }
        
        // Customize its position, scale, etc.
        modelEntity.position = SIMD3(x: 0, y: 0, z: 0)
        modelEntity.scale = SIMD3(repeating: 1.0)
        
        self.airplaneEntity = modelEntity
    }
}






