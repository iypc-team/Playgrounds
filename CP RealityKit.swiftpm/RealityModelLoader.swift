// CP RealityKit  11/15/2025- initial commit
// 

import RealityKit

class RealityModelLoader {
    static func loadModel(named modelName: String) -> Entity? {
        do {
            let modelEntity = try Entity.load(named: modelName)
            return modelEntity
        } catch {
            print("Failed to load model \(modelName): \(error)")
            return nil
        }
    }
}

