// 
// 

import RealityKit
import Combine

class AirplaneViewModel: ObservableObject {
    @Published var modelEntity: ModelEntity?    // The loaded 3D model entity
    @Published var errorMessage: String?       // Error messaging for debugging
    
    private var subscriptions = Set<AnyCancellable>()
    
    func loadAirplaneModel() {
        let airplane = AirplaneModel(filename: "Airplane")
        
        // Validate the model URL
        guard let modelURL = airplane.getModelURL() else {
            errorMessage = "Unable to locate Airplane.usdz file in the app bundle."
            return
        }
        
        // Load the RealityKit Model
        ModelEntity.loadModelAsync(contentsOf: modelURL)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Successfully loaded Airplane.usdz")
                case .failure(let error):
                    self.errorMessage = "Failed to load the model: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] modelEntity in
                self?.modelEntity = modelEntity
            }
            .store(in: &subscriptions)
    }
}
