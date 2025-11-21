// 
// 

import Foundation
import RealityKit
import SwiftUI

class AirplaneViewModel: ObservableObject {
    @Published var airplaneEntity: ModelEntity?
    @Published var currentTransform: Transform = .identity
    
    func loadModel() {
        Task {
            if let entity = try? await ModelEntity(named: "Airplane") {
                await MainActor.run {
                    self.airplaneEntity = entity
                }
            }
        }
    }
}
