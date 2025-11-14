// 
// 

import Foundation
import Combine
import SceneKit
import RealityKit
import UIKit

final class AirplaneViewModel: ObservableObject {
    // For SceneKit rendering (recommended when no ARView)
    @Published var scnScene: SCNScene?
    
    // Optional: keep the loaded RealityKit ModelEntity if you want later AR/RealityKit usage
    @Published var modelEntity: ModelEntity?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // noop
    }
    
    /// Load the USDZ from the app bundle (synchronous SceneKit method)
    func loadForSceneKit(named fileName: String = "Airplane.usdz") {
        // Loads SCNScene directly from bundle; SCNScene can load usdz
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                let scene = try SCNScene(url: url, options: nil)
                // optionally configure scene (lighting, camera, scale)
                DispatchQueue.main.async {
                    self.scnScene = scene
                }
            } catch {
                print("SceneKit failed to load \(fileName):", error)
                DispatchQueue.main.async {
                    self.scnScene = nil
                }
            }
        } else {
            print("File not found in bundle: \(fileName)")
            scnScene = nil
        }
    }
    
    /// Async RealityKit ModelEntity loader (keeps the modelEntity for later use)
    /// NOTE: Does NOT render anything itself — RealityKit requires an ARView or renderer to show it
    func loadForRealityKit(named fileName: String = "Airplane.usdz") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("File not found in bundle: \(fileName)")
            return
        }
        
        // ModelEntity.loadModelAsync returns a Combine publisher on iOS 16
        ModelEntity.loadModelAsync(contentsOf: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(err) = completion {
                    print("RealityKit load failed:", err)
                }
            }, receiveValue: { entity in
                self.modelEntity = entity
            })
            .store(in: &cancellables)
    }
    
    /// Convenience: load both (SceneKit for display + RealityKit for later)
    func loadAll(named fileName: String = "Airplane.usdz") {
        loadForSceneKit(named: fileName)
        loadForRealityKit(named: fileName)
    }
}
