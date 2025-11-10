// 
// 

// RealityViewModel.swift
import Foundation
import RealityKit
import Combine
import ARKit

final class RealityViewModel: ObservableObject {
    @Published var modelEntity: ModelEntity?
    @Published var errorMessage: String?
    
    private var cancellable: Cancellable?
    
    // RealityViewModel.swift
    func scaleModel(to factor: Float) {
        modelEntity?.transform.scale = SIMD3<Float>(repeating: factor)
    }
    
    func loadModel(named name: String = "Airplane.usdz") {
        // Uses RealityKit's async loader
        cancellable = ModelEntity.loadModelAsync(named: name)
            .sink(receiveCompletion: { completion in
                if case let .failure(err) = completion {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load: \(err.localizedDescription)"
                    }
                }
            }, receiveValue: { model in
                DispatchQueue.main.async {
                    self.modelEntity = model
                    self.errorMessage = nil
                }
            })
    }
    
    deinit {
        cancellable?.cancel()
    }
}
