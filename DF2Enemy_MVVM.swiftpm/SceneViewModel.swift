//  SceneViewModel.swift
//  DF2Enemy_MVVM.swiftpm
//  

import SwiftUI
import SceneKit

class SceneViewModel: ObservableObject {
    @Published var isAnimating: Bool = false
    
    // Managers for separated concerns
    private let universeManager = UniverseSceneManager()
    
    private let enemyManager = EnemySceneManager()
    
    func setupUniverse() throws -> SCNScene {
        return try universeManager.setupUniverse()
    }
    
    func setupEnemyScene() throws -> SCNScene {
        return try enemyManager.setupEnemyScene()
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
