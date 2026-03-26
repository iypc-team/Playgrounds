//  OrientationManager.swift
//  

import UIKit
import Combine

/// Shared orientation controller used by both SwiftUI views and UIKit delegates.
final class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    /// Current orientation mask used by the app.
    @Published private(set) var mask: UIInterfaceOrientationMask = .all
    
    private init() {}
    
    /// Update the mask and request UIKit to apply it.
    @MainActor
    func set(_ newMask: UIInterfaceOrientationMask) {
        guard mask != newMask else { return }
        mask = newMask
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

