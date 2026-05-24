// RealityViewModel.swift
// scale

import Foundation
import RealityKit
import Combine
import ARKit

final class RealityViewModel: ObservableObject {
    @Published var modelEntity: ModelEntity?
    @Published var errorMessage: String?
    @Published var scale: Float = 1.0
    
    private var cancellable: Cancellable?
    private var hasLoaded = false
    
    // RealityViewModel.swift
    func scaleModel(to factor: Float) {
        scale = factor
        modelEntity?.transform.scale = SIMD3<Float>(repeating: factor)
    }
    
    func loadModel(named name: String = "Airplane.usdz") {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        // Uses RealityKit's async loader
        cancellable = ModelEntity.loadModelAsync(named: name)
            .sink(receiveCompletion: { completion in
                if case let .failure(err) = completion {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load: \(err.localizedDescription)"
                        self.hasLoaded = false
                    }
                }
            }, receiveValue: { model in
                DispatchQueue.main.async {
                    model.transform.scale = SIMD3<Float>(repeating: self.scale)
                    self.modelEntity = model
                    self.errorMessage = nil
                }
            })
    }
    
    deinit {
        cancellable?.cancel()
    }
}
