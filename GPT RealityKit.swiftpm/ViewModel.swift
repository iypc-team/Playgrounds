// 
// 

import SwiftUI
import RealityKit
import Combine
import SceneKit

final class AirplaneViewModel: ObservableObject {
    @Published var modelEntity: ModelEntity?
    @Published var scene: SCNScene?
    @Published var error: Error?
    
    private let model = AirplaneModel()
    private var cancellables = Set<AnyCancellable>()
    
    func load() {
        // Load RealityKit entity (for logic or transforms)
        model.loadModelEntity()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error = err
                }
            } receiveValue: { [weak self] entity in
                self?.modelEntity = entity
                
                // Also load SceneKit version for rendering
                if let scene = try? SCNScene(named: "Airplane.usdz") {
                    self?.scene = scene
                }
            }
            .store(in: &cancellables)
    }
}
