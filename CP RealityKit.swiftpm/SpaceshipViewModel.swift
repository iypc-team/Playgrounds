// 
// 

import Combine
import RealityKit

final class SpaceshipViewModel: ObservableObject {
    @Published var spaceshipEntity: Entity?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSpaceship()
    }
    
    private func loadSpaceship() {
        Entity.loadModelAsync(named: "Spaceship")
            .sink { completion in
                if case let .failure(error) = completion {
                    print("❌ Failed to load spaceship: \(error)")
                }
            } receiveValue: { [weak self] entity in
                entity.scale = SIMD3<Float>(repeating: 0.5)
                self?.spaceshipEntity = entity
            }
            .store(in: &cancellables)
    }
}

