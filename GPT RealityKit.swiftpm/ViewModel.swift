// 
// 

import SwiftUI
import RealityKit
import Combine

final class AirplaneViewModel: ObservableObject {
    @Published var modelEntity: ModelEntity?
    @Published var error: Error?
    
    private let model = AirplaneModel()
    private var cancellables = Set<AnyCancellable>()
    
    func load() {
        model.loadModelEntity()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error = err
                }
            } receiveValue: { [weak self] entity in
                self?.modelEntity = entity
            }
            .store(in: &cancellables)
    }
}
