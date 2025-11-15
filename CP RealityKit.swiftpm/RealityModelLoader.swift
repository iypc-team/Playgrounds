// CP RealityKit  11/15/2025- initial commit
// 

import SwiftUI
import RealityKit

class RealityModelLoader {
    private var cache: [String: Entity] = [:]
    
    // Load models asynchronously and cache them for reuse
    func loadModel(named modelName: String, completion: @escaping (Entity?) -> Void) {
        if let cachedEntity = cache[modelName] {
            completion(cachedEntity)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let entity = try Entity.load(named: modelName)
                self.cache[modelName] = entity
                DispatchQueue.main.async {
                    completion(entity)
                }
            } catch {
                print("Failed to load model \(modelName): \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

