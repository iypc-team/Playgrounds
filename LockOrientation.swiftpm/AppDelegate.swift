//  AppDelegate.swift
//  

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // Static variable to control supported orientations across the app
    // Default allows all orientations for flexibility
    static var orientationLock: UIInterfaceOrientationMask = .all {
        didSet {
            // Optional: Log changes for debugging
            print("Orientation lock changed to: \(orientationLock)")
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
