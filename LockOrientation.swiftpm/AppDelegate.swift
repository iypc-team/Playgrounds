//  AppDelegate.swift
//  Project: LockOrientation.swiftpm
//  

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // Static variable to control supported orientations across the app
    // Default allows all orientations for flexibility
    static var orientationLock: UIInterfaceOrientationMask = .all {
        didSet {
            // Improved: Gated debug logging
#if DEBUG
            print("Orientation lock changed to: \(orientationLock)")
#endif
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
