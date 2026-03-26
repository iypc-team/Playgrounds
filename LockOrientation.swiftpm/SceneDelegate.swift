//  SceneDelegate.swift
//  

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // Moved from AppDelegate: Static variable to control supported orientations across the app
    static var orientationLock: UIInterfaceOrientationMask = .all {
        didSet {
#if DEBUG
            print("Orientation lock changed to: \(orientationLock)")
#endif
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return SceneDelegate.orientationLock
    }
}
