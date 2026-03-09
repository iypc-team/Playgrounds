//
//  SceneViewModel.swift
//  DF2Enemy_MVVM.swiftpm
//
//  SceneViewModel: Handles scene logic, setup, and state, delegating to specialized managers.
//

import SwiftUI
import SceneKit

class SceneViewModel: ObservableObject {
    @Published var enemyShip: EnemyShipModel = EnemyShipModel()
    @Published var isAnimating: Bool = false
    
    // Managers for separated concerns
    private let universeManager = UniverseSceneManager()
    private let enemyManager = EnemySceneManager()
    
    func setupUniverse() -> SCNScene {
        return universeManager.setupUniverse()
    }
    
    func setupEnemyScene() -> SCNScene {
        return enemyManager.setupEnemyScene()
    }
    
    func startAnimation() {
        enemyManager.startAnimation()
        isAnimating = true
    }
    
    func stopAnimation() {
        enemyManager.stopAnimation()
        isAnimating = false
    }
    
    // Additional SceneViewModel-specific logic can be added here
    // e.g., coordinating between universe and enemy scenes, handling animations, etc.
}
